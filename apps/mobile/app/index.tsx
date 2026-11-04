import { Redirect } from 'expo-router';

// Auth guard arrives with feat/mobile-auth; until then go straight to the tabs.
export default function Index() {
  return <Redirect href="/discover" />;
}
