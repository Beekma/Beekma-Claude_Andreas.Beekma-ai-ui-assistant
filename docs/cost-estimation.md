# Cost Estimation

## Pricing assumptions

Based on OpenAI pricing for `gpt-4.1-mini` (verified May 2026):
- Input:  ca. USD 0.40 per 1M tokens
- Output: ca. USD 1.60 per 1M tokens

## Measured tokens (TC-1, Playground)

- Input:  124 tokens
- Output: 43 tokens

## Cost per typical request

- Input cost:  124 / 1M * 0.40 = USD 0.0000496
- Output cost: 43  / 1M * 1.60 = USD 0.0000688
- **Total: ~USD 0.000118 per request** (about 0.012 Rappen)

## Projected monthly cost (worst case at limit)

- 30 requests/day * 30 days = 900 requests/month
- 900 * 0.000118 = **~USD 0.11/month**

## Risk envelope

Even with significant prompt growth (Knowledge Base injection,
caching misses, rare model upgrades), the projected cost stays
well below USD 1/month.

OpenAI hard limit configured: USD 5/month.
This is approximately 50x the realistic worst case.
