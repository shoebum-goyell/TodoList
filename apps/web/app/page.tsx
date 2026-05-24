"use client";

import { useTodos } from "@/lib/useTodos";
import AddTodoForm from "@/components/AddTodoForm";
import TodoList from "@/components/TodoList";

export default function Home() {
  const { todos, addTodo, toggleTodo, deleteTodo } = useTodos();

  return (
    <main className="mx-auto max-w-lg px-4 py-12">
      <h1 className="mb-8 text-2xl font-bold text-gray-900">My Todos</h1>
      <div className="flex flex-col gap-6">
        <AddTodoForm onAdd={addTodo} />
        <TodoList todos={todos} onToggle={toggleTodo} onDelete={deleteTodo} />
      </div>
    </main>
  );
}
