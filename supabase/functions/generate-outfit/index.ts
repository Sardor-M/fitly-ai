// Supabase Edge Function to generate outfits via Replicate API
// This avoids CORS issues by calling Replicate from the server

/// <reference path="./types.d.ts" />

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const REPLICATE_API_TOKEN = Deno.env.get('REPLICATE_API_TOKEN')
const OOTD_MODEL = 'viktorfa/oot_diffusion:9f8fa4956970dde99689af7488157a30aa152e23953526a605df1d77598343d7'

// Helper function to create CORS headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

serve(async (req) => {
  /* handle CORS preflight */
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
            'Content-Type': 'application/json',
            ...corsHeaders,
          } 
        }
      )
    }

    /* verify user is authenticated */
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    
    if (!supabaseUrl || !supabaseServiceKey) {
      return new Response(
        JSON.stringify({ error: 'Supabase configuration missing' }),
        { 
          status: 500, 
          headers: { 
            'Content-Type': 'application/json',
            ...corsHeaders,
          } 
        }
      )
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      global: {
        headers: { Authorization: authHeader },
      },
    })

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized: Invalid or missing token' }),
        { 
          status: 401, 
          headers: { 
            'Content-Type': 'application/json',
            ...corsHeaders,
          } 
        }
      )
    }

    const { selfie_base64, description, index } = await req.json()

    if (!selfie_base64 || !description) {
      return new Response(
        JSON.stringify({ error: 'Missing required parameters' }),
        { 
          status: 400, 
          headers: { 
            'Content-Type': 'application/json',
            ...corsHeaders,
          } 
        }
      )
    }

    if (!REPLICATE_API_TOKEN) {
      console.error('REPLICATE_API_TOKEN is not set')
      return new Response(
        JSON.stringify({ error: 'REPLICATE_API_TOKEN not configured' }),
        { 
          status: 500, 
          headers: { 
            'Content-Type': 'application/json',
            ...corsHeaders,
          } 
        }
      )
    }

    /* create prediction with varied seed for different outputs */
    const uniqueSeed = Math.floor(Date.now() / 1000) + (index * 1000) + Math.floor(Math.random() * 1000)
    
    const predictionResponse = await fetch('https://api.replicate.com/v1/predictions', {
      method: 'POST',
      headers: {
        'Authorization': `Token ${REPLICATE_API_TOKEN}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        version: OOTD_MODEL,
        input: {
          human_img: `data:image/jpeg;base64,${selfie_base64}`,
          garment_des: description,
          category: 'fullbody',
          seed: uniqueSeed,
        },
      }),
    })

    if (!predictionResponse.ok) {
      const error = await predictionResponse.text()
      return new Response(
        JSON.stringify({ error: `Replicate API error: ${error}` }),
        { 
          status: predictionResponse.status, 
          headers: { 
            'Content-Type': 'application/json',
            ...corsHeaders,
          } 
        }
      )
    }

    const prediction = await predictionResponse.json()
    const predictionId = prediction.id

    if (!predictionId) {
      return new Response(
        JSON.stringify({ error: 'No prediction ID returned' }),
        { 
          status: 500, 
          headers: { 
            'Content-Type': 'application/json',
            ...corsHeaders,
          } 
        }
      )
    }

    const maxAttempts = 60
    const delay = 5000 // 5 seconds

    for (let i = 0; i < maxAttempts; i++) {
      await new Promise(resolve => setTimeout(resolve, delay))

      const statusResponse = await fetch(
        `https://api.replicate.com/v1/predictions/${predictionId}`,
        {
          headers: {
            'Authorization': `Token ${REPLICATE_API_TOKEN}`,
          },
        }
      )

      if (!statusResponse.ok) {
        continue
      }

      const statusData = await statusResponse.json()
      const status = statusData.status

      if (status === 'succeeded' || status === 'completed') {
        const output = statusData.output
        let imageUrl: string | null = null

        if (typeof output === 'string') {
          imageUrl = output
        } else if (Array.isArray(output) && output.length > 0) {
          imageUrl = output[0]
        }

        if (imageUrl) {
          return new Response(
            JSON.stringify({ image_url: imageUrl }),
            {
              status: 200,
              headers: {
                'Content-Type': 'application/json',
                ...corsHeaders,
              },
            }
          )
        }
      } else if (status === 'failed' || status === 'canceled') {
        return new Response(
          JSON.stringify({ error: `Prediction failed: ${statusData.error || 'Unknown error'}` }),
          { 
            status: 500, 
            headers: { 
              'Content-Type': 'application/json',
              ...corsHeaders,
            } 
          }
        )
      }
    }

    return new Response(
      JSON.stringify({ error: 'Timeout: Prediction took too long' }),
      { 
        status: 504, 
        headers: { 
          'Content-Type': 'application/json',
          ...corsHeaders,
        } 
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message || 'Internal server error' }),
      {
        status: 500,
        headers: {
          'Content-Type': 'application/json',
          ...corsHeaders,
        },
      }
    )
  }
})

