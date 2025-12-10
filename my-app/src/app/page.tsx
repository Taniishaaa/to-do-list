import { redirect } from 'next/navigation';

export default function Home() {
  // This triggers a server-side redirect instantly
  redirect('/dashboard/today');
}