/**
 * Company service lines — edit here to update Services page and home “What we do”.
 */
export interface ServiceOffering {
  slug: string;
  title: string;
  summary: string;
  highlights: string[];
}

export const serviceOfferings: ServiceOffering[] = [
  {
    slug: "software",
    title: "Software engineering & platforms",
    summary:
      "Design, build, and modernize applications — APIs, integrations, cloud-native systems, and reliable release pipelines.",
    highlights: [
      "Product-oriented squads and milestone-based delivery",
      "Quality gates, observability, and production readiness baked in",
    ],
  },
  {
    slug: "ai",
    title: "AI solutions",
    summary:
      "Practical AI adoption: automation, intelligent workflows, LLM-assisted tooling, and responsible rollout tied to your security and data posture.",
    highlights: [
      "Use-case discovery, PoCs, and production hardening",
      "Ops-aware AI: monitoring, cost controls, and governance patterns",
    ],
  },
  {
    slug: "consulting",
    title: "Consulting & advisory",
    summary:
      "Architecture reviews, cloud & DevOps maturity, incident readiness, and roadmaps that match how your teams actually work.",
    highlights: [
      "Executive-ready outcomes with engineering-level depth",
      "Short engagements through multi-quarter transformation partners",
    ],
  },
  {
    slug: "staffing",
    title: "Staffing & talent",
    summary:
      "Skilled engineers for cloud, DevOps, platform, SRE, and AI-augmented delivery — aligned to your stack and ways of working.",
    highlights: [
      "Ramp-up focused on your environments and standards",
      "Optional mentorship through OpsForge Academy tracks",
    ],
  },
  {
    slug: "training",
    title: "OpsForge Academy — DevOps & AI training",
    summary:
      "Hands-on programs for teams and individuals: production-grade DevOps, Kubernetes, cloud, automation, and AI for operators.",
    highlights: [
      "Enterprise scenarios, not slide-only theory",
      "See full program detail on the Training page",
    ],
  },
];
