LOCAL SERVICE FINDER — NALLASOPARA EAST
Public shared-database edition

This project lets anyone search published essential services and submit missing-service suggestions. Suggestions stay pending until an authorized administrator reviews them. Admin access is enforced by Supabase authentication and Row Level Security.

START HERE: Read SETUP.md completely.
1. Create a Supabase project.
2. Run supabase-schema.sql in Supabase SQL Editor.
3. Add your project URL and anon/publishable key to config.js. Never use a service_role/secret key in the browser.
4. Create an admin user in Supabase Authentication, then insert that user's UUID into public.admin_users as instructed in SETUP.md.
5. Test locally with: py -m http.server 8000
6. Deploy the folder to a static host over HTTPS to make it publicly available.

Pages:
index.html — public search, map, filters, distance sort, directions
suggest.html — public submission queue form
admin.html — administrator sign-in, review, add/edit/delete, publish/unpublish

No sample service records are included. Add only real, verified survey data. Public suggestions do not auto-publish. This package does not send email notifications; it places submissions in the private admin review queue.

IMPORTANT: Before testing the admin dashboard, run compatibility-migration.sql once in Supabase SQL Editor. config.js is configured for the Supabase project supplied by the project owner.
