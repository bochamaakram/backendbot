# GEO (Generative Engine Optimization) Blueprint

## 1. Core Responsibility
Generative Engine Optimization (GEO) focuses on optimizing content and metadata to be cited by AI-powered search engines (e.g., ChatGPT, Claude, Perplexity, Gemini). While SEO focuses on ranking in Google, GEO focuses on being the source material for AI answers. The backend API is responsible for providing structured, easily extractable data, maintaining proper crawler access controls, and emitting strong entity signals.

## 2. RAG Retrieval Factors
AI engines select content to cite based on Retrieval-Augmented Generation (RAG) principles. The backend must serve content optimized for these weights:
- **Semantic relevance (~40%)**: Clear, direct answers to specific queries.
- **Keyword match (~20%)**: Terminology alignment.
- **Authority signals (~15%)**: Established entity trust and expert credentials.
- **Source diversity (~15%)**: Unique perspectives or data not found everywhere.
- **Freshness (~10%)**: Recent and updated timestamps.

## 3. Schema Definition & Technical Elements
To maximize AI extraction, the API must supply rigorous structured data alongside content:
- **Article Schema:** Must include precise `datePublished` and `dateModified` timestamps. AI engines strongly prefer fresh, dated content.
- **Person/Organization Schema:** Must include author credentials, titles, and `sameAs` entity links to build authority.
- **FAQPage Schema:** Must be auto-generated for any Q&A sections. Direct Q&A format is highly favored by AI models.
- **Summary Fields:** The API should enforce a `summary` or `tl_dr` field on long-form content, as AIs rely on concise summaries.

## 4. Crawler Access Control (Robots.txt)
The backend must define access rules for key AI User-Agents in the dynamic `GET /v1/seo/robots.txt` endpoint:
- `GPTBot` (OpenAI / ChatGPT)
- `Claude-Web` (Anthropic / Claude)
- `PerplexityBot` (Perplexity)
- `Googlebot` (Gemini - shared with standard Google search)

**Access Strategy Configuration:**
The tenant configuration (`tenants.config.geo_defaults`) should allow toggling AI bot access:
- **Allow all:** To maximize AI citations and visibility.
- **Selective Blocking:** E.g., block `GPTBot` to prevent model training while allowing `PerplexityBot` for search citations.

## 5. Entity Building & Data Structuring
AI engines need to trust the source. The backend supports this by:
- Storing and serving consistent entity information (brand name, location, parent organization).
- Exposing original statistics, expert quotes, and comparison data in structured JSON formats that frontends can render semantically.
- Ensuring all API payloads that contain content also include the author's full name and credentials.

## 6. Anti-Patterns & Validation
The back-office editor and API validation must prevent GEO anti-patterns:
- **Hard Error:** Publishing an article without a `datePublished`.
- **Soft Warning:** Missing author credentials or vague attributions.
- **Soft Warning:** Content blocks lacking clear, extractable definitions or structured tables when comparing items.
