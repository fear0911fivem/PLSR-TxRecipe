declare global {
  interface Window {
    invokeNative?: unknown;
    GetParentResourceName?: () => string;
  }
}

export const isEnvBrowser = (): boolean => !window.invokeNative;

const resourceName = (): string =>
  window.GetParentResourceName?.() ?? 'pulsar-apartments-WALKINS';

export async function fetchNui<T = unknown>(
  endpoint: string,
  data?: unknown
): Promise<T> {
  const resp = await fetch(`https://${resourceName()}/${endpoint}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data ?? {}),
  });
  return resp.json() as Promise<T>;
}
