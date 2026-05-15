# SEO Blueprint

## 1. Core Responsibility
The backend API is the single owner of all SEO data. It stores, resolves, and serves SEO metadata as JSON — it never renders HTML head tags. That is the frontend consumer's responsibility.

## 2. Schema Definition
Every page has a `seo_meta` JSONB column validated by a strict Zod schema. The core fields are:
- `title` (10–70 chars)
- `description` (50–170 chars)
- `canonical_url`
- **Robots directives:** `index`, `follow`, `max_snippet`, `max_image_preview`
- **Open Graph tags:** `title`, `description`, `image` (as media UUID resolved to CDN URL), `type`, `locale`
- **Twitter Card tags:** card `type`, `title`, `description`, `image`
- **JSON-LD structured data:** `WebPage`, `Article`, `FAQPage`, `Product`, `Organization`, `BreadcrumbList`, `LocalBusiness`
- `hreflang` alternate language links
- **Optional redirect:** `301`, `302`, or `308` with target URL

## 3. Resolution Cascade
SEO data is resolved through a 3-layer cascade:
1. **Layer 1 (Page-level):** From `pages.seo_meta` — highest priority.
2. **Layer 2 (Tenant Defaults):** From `tenants.config.seo_defaults` — provides fallback OG image, site name, social handles.
3. **Layer 3 (System Defaults):** Hardcoded in the API config — safe fallbacks like `robots.index=true`, `og.type='website'`, `twitter.card='summary_large_image'`, `jsonld.type='WebPage'`.

The merge logic is a **deep merge** where page overrides tenant, and tenant overrides system. The API response includes a `_meta.resolution_source` object that tells the back-office editor which layer each value came from.

## 4. Auto-generated JSON-LD
The API auto-generates JSON-LD structured data based on component types:
- **FAQ components** with `generate_jsonld: true` produce `FAQPage` schema.
- **Pages** with `og.type: 'article'` produce `Article` schema with `datePublished` and `author`.
- **Navigation components** produce `BreadcrumbList`.
- Custom JSON-LD can be added via `seo_meta.jsonld.custom` for edge cases.

The API pre-assembles the full JSON-LD object so consumers just inject it as a `<script type="application/ld+json">` tag.

## 5. Sitemap and Robots.txt
- **Sitemap:** Dynamic, served at `GET /v1/seo/sitemap.xml`.
  - Only includes pages with `status = 'published'` and `robots.index = true`.
  - Priority is assigned automatically: homepage gets `1.0`, top-level pages `0.8`, blog/content pages `0.6`, legal/policy pages `0.3`.
  - The `lastmod` value comes from `pages.updated_at`.
  - Cached in Redis for 1 hour and regenerated on page publish or unpublish.
  - Max 50,000 URLs per sitemap — use a sitemap index for larger tenants.
- **Robots.txt:** Served at `GET /v1/seo/robots.txt`.
  - Blocks `/admin/` and `/api/` paths while pointing to the sitemap URL.

## 6. Search Engine Indexing
On page publish, the API submits the URL to search engines via the **IndexNow API** for instant discovery.
- The submission is circuit-breaker protected with max 3 retry attempts on 5xx errors.
- IndexNow is per-tenant and optional — the key is stored in `tenants.config.seo_defaults.indexnow_key`.
- For enterprise tenants, **Google Indexing API** is optionally available with a cap of 200 submissions per day using service account credentials.

## 7. Redirect Rules
When a page has `seo_meta.redirect` set, the API returns a 3xx status with a `Location` header.
- Max redirect chain length is 1 hop — the API validates the target is not also a redirect.
- Self-redirects and cross-tenant redirects are blocked.
- Query strings are preserved by default.
- Use `301` for permanent moves (SEO weight transfer), `308` to preserve HTTP method, and `302` for temporary moves only.

## 8. Back-Office Validation and Editing
- **Validation:** Happens on save.
  - Title and description length warnings are **soft** (save allowed but warning returned).
  - Invalid canonical URLs, missing OG image media references, self-redirects, and redirect chains are **hard errors** that block the save.
- **Editor Features:** The back-office SEO editor tab shows a real-time SERP preview, character counters with color coding (green/yellow/red), resolution source indicators per field, and an OG image picker connected to the Media Library.

## 9. Robots Directives by Page Type
- **Published content pages:** `index`, `follow`
- **Archived pages:** `noindex`, `follow` (to preserve link equity)
- **Paginated list pages:** `noindex`, `follow` (to prevent duplicate thin content)
- **Draft and review pages:** Not served via the public API at all.
- **Error pages:** `noindex`, `nofollow`

## 10. Pre-launch SEO Checklist & Performance
- Every published page must have title (30–60 chars), description (120–160 chars), and OG image (set or inherited).
- No duplicate slugs within the same locale.
- Sitemap must return valid XML.
- Robots.txt must be accessible.
- No redirect chains.
- Canonical URL set on all published pages.
- JSON-LD validates via Google's testing tool.
- Hreflang tags reference existing pages.
- **Performance Targets:** API response times must be under 50ms cached and 200ms uncached for page resolution, 30ms cached for SEO meta resolution, and 100ms cached for sitemap generation.
