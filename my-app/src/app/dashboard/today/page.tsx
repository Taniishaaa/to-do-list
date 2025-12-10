"use client"; 

import { useEffect, useState } from "react";
import { createClient } from "@supabase/supabase-js";

//Initialize Supabase
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);

export default function DashboardToday() {
  const [tasks, setTasks] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  // Function to fetch tasks due "Today"
  async function fetchTasks() {
    setLoading(true);
    setError("");

    // Get start and end of today in UTC
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const { data, error } = await supabase
      .from("tasks")
      .select("*")
      // Filter: due_at is greater than start of today AND less than tomorrow
      .gte("due_at", today.toISOString())
      .lt("due_at", tomorrow.toISOString())
      .order("due_at", { ascending: true });

    if (error) {
      setError("Failed to fetch tasks");
      console.error(error);
    } else {
      setTasks(data || []);
    }
    setLoading(false);
  }

  // Run fetch on page load
  useEffect(() => {
    fetchTasks();
  }, []);

  // Function to Mark Complete
  async function markComplete(taskId: string) {
    const { error } = await supabase
      .from("tasks")
      .update({ status: "completed" }) 
      .eq("id", taskId);

    if (error) {
      alert("Error updating task");
    } else {
      fetchTasks();
    }
  }

  return (
    <div className="p-10 max-w-4xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Tasks Due Today</h1>

      {loading && <p>Loading tasks...</p>}
      {error && <p className="text-red-500">{error}</p>}

      {!loading && !error && (
        <div className="border rounded-lg overflow-hidden shadow-sm">
          <table className="w-full text-left border-collapse">
            <thead className="bg-gray-100">
              <tr>
                <th className="p-4 border-b">Title</th>
                <th className="p-4 border-b">Type</th>
                <th className="p-4 border-b">Status</th>
                <th className="p-4 border-b">Action</th>
              </tr>
            </thead>
            <tbody>
              {tasks.length === 0 ? (
                <tr>
                  <td colSpan={4} className="p-4 text-center text-gray-500">
                    No tasks due today!
                  </td>
                </tr>
              ) : (
                tasks.map((task) => (
                  <tr key={task.id} className="hover:bg-gray-50">
                    <td className="p-4 border-b">{task.title || "Untitled Task"}</td>
                    <td className="p-4 border-b">
                      <span className="px-2 py-1 bg-blue-100 text-blue-800 text-xs rounded-full">
                        {task.type}
                      </span>
                    </td>
                    <td className="p-4 border-b capitalize">{task.status}</td>
                    <td className="p-4 border-b">
                      {task.status !== "completed" && (
                        <button
                          onClick={() => markComplete(task.id)}
                          className="bg-green-600 text-white px-4 py-1 rounded hover:bg-green-700 text-sm transition"
                        >
                          Mark Complete
                        </button>
                      )}
                      {task.status === "completed" && (
                        <span className="text-green-600 font-medium">✓ Done</span>
                      )}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}