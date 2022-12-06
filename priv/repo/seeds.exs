# Postgresql protocol has a limit of maximum parameters (65535)
# Choose the right batch size based on the number of parameters we can
# insert at a time.
# In this case, each of rows we are inserting 3 parameters so the maximum
# batch size should be 65535/2 ~= 32766

batch_size = 32766

placeholders = %{timestamp: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)}

Enum.to_list(0..999_999)
|> Enum.map(fn _ ->
  %{inserted_at: {:placeholder, :timestamp}, updated_at: {:placeholder, :timestamp}}
end)
|> Enum.chunk_every(batch_size)
|> Enum.each(fn users ->
  Rando.Repo.insert_all("users", users, placeholders: placeholders)
end)

# Runs in ~5s
