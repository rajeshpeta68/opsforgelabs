/** Planned blog posts — edit here instead of editing blog page markup. */
export interface BlogTopic {
  title: string;
  description: string;
  status: "Planned" | "Draft" | "Published";
}

export const blogTopics: BlogTopic[] = [
  {
    title: "Kubernetes Troubleshooting Scenarios",
    description: "Pod lifecycle, networking, storage, and control-plane signals.",
    status: "Planned",
  },
  {
    title: "Real Production Incidents",
    description: "Postmortem patterns and what interviewers listen for.",
    status: "Planned",
  },
  {
    title: "Linux Commands Every DevOps Engineer Should Know",
    description: "Debugging and observability from the shell.",
    status: "Planned",
  },
  {
    title: "How AI is Changing DevOps",
    description: "Practical automation vs. hype.",
    status: "Planned",
  },
  {
    title: "CI/CD Best Practices",
    description: "Pipelines, environments, and safe releases.",
    status: "Planned",
  },
  {
    title: "Monitoring & Observability Fundamentals",
    description: "Metrics, logs, traces, and SLO thinking.",
    status: "Planned",
  },
  {
    title: "Common DevOps Interview Questions",
    description: "How to answer with production context.",
    status: "Planned",
  },
  {
    title: "Infrastructure Automation Patterns",
    description: "IaC, GitOps, and operational guardrails.",
    status: "Planned",
  },
];
