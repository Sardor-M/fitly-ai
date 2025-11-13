/// <reference path="./types.d.ts" />

/** 
  Supabase Edge Function to generate outfits 
  via Segmind API (fast image generation)
*/

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const SEGMIND_API_KEY = Deno.env.get('SEGMIND_API_KEY')
const SEGMIND_BASE_URL = 'https://api.segmind.com/v1'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const authHeader = req.headers.get('authorization') || req.headers.get('Authorization')
    
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        { 
          status: 401, 
          headers: { 
            ...corsHeaders, 
            'Content-Type': 'application/json' 
          } 
        }
      )
    }

    /** 
      Verify user authentication
    */
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    
    if (!supabaseUrl || !supabaseServiceKey) {
      return new Response(
        JSON.stringify({ error: 'Supabase configuration missing' }),
        { 
          status: 500, 
          headers: { 
            ...corsHeaders, 
            'Content-Type': 'application/json' 
          } 
        }
      )
    }
    
    /** 
      Create client with user auth for authentication check
    */
    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      global: { 
        headers: { Authorization: authHeader } 
      },
    })

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { 
          status: 401, 
          headers: { 
            ...corsHeaders, 
            'Content-Type': 'application/json' 
          } 
        }
      )
    }

    /** 
      Create a separate client with service role key only for storage operations
      This bypasses RLS policies since service role has full access
    */
    const supabaseStorage = createClient(supabaseUrl, supabaseServiceKey)

    const { selfie_base64, description, index } = await req.json()

    if (!description) {
      return new Response(
        JSON.stringify({ error: 'Missing required parameters: description is required' }),
        { 
          status: 400, 
          headers: { 
            ...corsHeaders, 
            'Content-Type': 'application/json' 
          } 
        }
      )
    }

    if (!SEGMIND_API_KEY) {
      console.error('SEGMIND_API_KEY is not set')
      return new Response(
        JSON.stringify({ error: 'SEGMIND_API_KEY not configured' }),
        { 
          status: 500, 
          headers: { 
            ...corsHeaders, 
            'Content-Type': 'application/json' 
          } 
        }
      )
    }

    /** 
      Using Segmind's working models - try sdxl1.0-txt2img first, fallback to realistic-vision-v5.1
    */
    const segmindEndpoint = `${SEGMIND_BASE_URL}/sdxl1.0-txt2img`
    /** const segmindEndpoint = `${SEGMIND_BASE_URL}/realistic-vision-v5.1` */
    
    /** 
      Extract style from description or use default
    */
    const style = description.includes('casual') ? 'casual' : 
                  description.includes('formal') ? 'formal' : 
                  description.includes('streetwear') ? 'streetwear' : 'fashion'
    
    const prompt = `Full body portrait, person wearing ${description}, ${style} style, fashion photography, studio lighting, high quality, detailed, professional model`
    const negativePrompt = "bad anatomy, blurry, low quality, deformed, ugly, distorted, extra limbs, missing limbs"

    const startTime = Date.now()
    
    const segmindResponse = await fetch(segmindEndpoint, {
      method: 'POST',
      headers: {
        'x-api-key': SEGMIND_API_KEY,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        prompt: prompt,
        negative_prompt: negativePrompt,
        samples: 1,
        scheduler: "DPM++ SDE",
        num_inference_steps: 25, 
        guidance_scale: 7.5, 
        seed: index ? (Math.floor(Date.now() / 1000) + (index * 1000) + Math.floor(Math.random() * 1000)) : Math.floor(Math.random() * 1000000),
        img_width: 768,
        img_height: 1024,
        base64: false,
        output_format: "url"
      }),
    })

    const endTime = Date.now()
    console.log(`Segmind API call took ${endTime - startTime}ms`)

    if (!segmindResponse.ok) {
      const error = await segmindResponse.text()
      console.error('Segmind API error:', error)
      return new Response(
        JSON.stringify({ error: `Segmind API error: ${error}` }),
        { 
          status: segmindResponse.status, 
          headers: { 
            ...corsHeaders, 
            'Content-Type': 'application/json' 
          } 
        }
      )
    }

    /** 
      Handle Segmind response - check content type first to determine how to read
    */
    const contentType = segmindResponse.headers.get('content-type') || ''
    let imageUrl: string | null = null
    
    /** 
      If Segmind returned binary image data, upload to storage
    */
    if (contentType.includes('image/')) {
      console.log('Segmind returned binary image data, uploading to storage...')
      try {
        /** 
          Read as arrayBuffer for binary data
        */
        const imageBuffer = await segmindResponse.arrayBuffer()
        const imageBytes = new Uint8Array(imageBuffer)
        
        /** 
          Determine file extension from content type
        */
        const fileExt = contentType.includes('jpeg') || contentType.includes('jpg') ? 'jpg' : 'png'
        const fileName = `outfits/${user.id}/${Date.now()}_${index || 0}.${fileExt}`
        /** 
          Use supabaseStorage client (service role only) to bypass RLS
        */
        const { data: uploadData, error: uploadError } = await supabaseStorage.storage
          .from('outfits')
          .upload(fileName, imageBytes, {
            contentType: contentType || 'image/jpeg',
            upsert: false
          })
        
        if (uploadError) {
          console.error('Storage upload error:', uploadError)
          throw new Error(`Storage bucket 'outfits' not found. Please create it in Supabase Storage. Error: ${uploadError.message}`)
        } else {
          const { data: urlData } = supabaseStorage.storage
            .from('outfits')
            .getPublicUrl(fileName)
          imageUrl = urlData.publicUrl
        }
      } catch (storageError) {
        console.error('Storage error:', storageError)
        throw new Error(`Failed to upload image to storage: ${storageError.message}`)
      }
    } else {
      /** 
        Try to read as JSON/text for URL response
      */
      try {
        const responseText = await segmindResponse.text()
        /** 
          Try to parse as JSON
        */
        try {
          const responseJson = JSON.parse(responseText)
          /** 
            Check multiple possible response formats for URL
          */
          if (responseJson.image) {
            imageUrl = responseJson.image
          } else if (responseJson.url) {
            imageUrl = responseJson.url
          } else if (responseJson.output) {
            imageUrl = typeof responseJson.output === 'string' ? responseJson.output : responseJson.output[0]
          } else if (responseJson.data) {
            if (typeof responseJson.data === 'string' && (responseJson.data.startsWith('http://') || responseJson.data.startsWith('https://'))) {
              imageUrl = responseJson.data
            } else if (responseJson.data.image) {
              imageUrl = responseJson.data.image
            } else if (responseJson.data.url) {
              imageUrl = responseJson.data.url
            } else if (Array.isArray(responseJson.data) && responseJson.data.length > 0) {
              imageUrl = responseJson.data[0]
            }
          } else if (Array.isArray(responseJson) && responseJson.length > 0) {
            imageUrl = responseJson[0]
          }
        } catch (jsonParseError) {
          const trimmedText = responseText.trim()
          if (trimmedText.startsWith('http://') || trimmedText.startsWith('https://')) {
            imageUrl = trimmedText
          } else {
            console.log('Response is not JSON and not a URL')
          }
        }
      } catch (textError) {
        console.error('Failed to read response as text:', textError)
        throw new Error('Failed to read Segmind API response')
      }
    }
    
    /** 
      If still no URL, log error with response details
    */
    if (!imageUrl) {
      console.error('Could not extract image URL from Segmind response')
      console.error('Content-Type:', contentType)
      throw new Error(`Unexpected response format from Segmind API. Content-Type: ${contentType}. Could not extract image URL.`)
    }
    
    
    if (imageUrl) {
      /** 
        here we store the generation in database (using existing outfits table)
      */
      try {
        await supabase
          .from('outfits')
          .insert({
            user_id: user.id,
            image_url: imageUrl,
            style: style,
            selfie_url: selfie_base64 ? `data:image/jpeg;base64,${selfie_base64.substring(0, 100)}...` : null,
            palette_name: description,
            created_at: new Date().toISOString()
          })
      } catch (dbError) {
        console.error('Error saving to database (non-critical):', dbError)
      }
      
      return new Response(
        JSON.stringify({ image_url: imageUrl }),
        { 
          status: 200, 
          headers: { 
            ...corsHeaders, 
            'Content-Type': 'application/json' 
          } 
        }
      )
    } else {
      console.error('No image URL extracted from Segmind response')
      return new Response(
        JSON.stringify({ error: 'No image generated from Segmind API' }),
        { 
          status: 500, 
          headers: { 
            ...corsHeaders, 
            'Content-Type': 'application/json' 
          } 
        }
      )
    }
  } catch (error) {
    console.error('Error in generate-outfit function:', error)
    return new Response(
      JSON.stringify({ error: error.message || 'Internal server error' }),
      { 
        status: 500, 
        headers: { 
          ...corsHeaders, 
          'Content-Type': 'application/json' 
        } 
      }
    )
  }
})
