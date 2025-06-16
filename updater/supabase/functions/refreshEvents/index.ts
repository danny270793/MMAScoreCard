import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';
import { Logger } from './libraries/logger.ts'
import { Sherdog } from './libraries/sherdog/index.ts'

const logger: Logger = new Logger('/index.ts')

Deno.serve(async (req)=>{
  try {
    logger.debug('function called')

    const sherdog: Sherdog = new Sherdog()
    logger.debug(`${sherdog}`)

    const url: string = Deno.env.get('SUPABASE_URL') ?? ''
    const key: string = Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    const supabase = createClient(url, key, {
      global: {
        headers: {
          Authorization: req.headers.get('Authorization')
        }
      }
    });
    const { data, error } = await supabase.from('events').select('*').eq('status', 'uppcoming');
    if (error) {
      throw error;
    }
    return new Response(JSON.stringify({
      data
    }), {
      headers: {
        'Content-Type': 'application/json'
      },
      status: 200
    });
  } catch (err) {
    return new Response(JSON.stringify({
      message: err?.message ?? err
    }), {
      headers: {
        'Content-Type': 'application/json'
      },
      status: 500
    });
  }
});
