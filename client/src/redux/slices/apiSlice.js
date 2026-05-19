import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";

// const API_URL = import.meta.env.VITE_APP_BASE_URL + "/api";
// const ru = "http://localhost:8800/api";
const API_URL = import.meta.env.VITE_APP_BASE_URL || "http://localhost:5000/api";

const baseQuery = fetchBaseQuery({ baseUrl: API_URL });

export const apiSlice = createApi({
  baseQuery,
  tagTypes: ["Task"],
  endpoints: (builder) => ({}),
});
