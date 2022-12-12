# Postgresql protocol has a limit of maximum parameters (65535)
# Choose the right batch size based on the number of parameters we can
# insert at a time.
# In this case, each of rows we are inserting 3 parameters so the maximum
# batch size should be 65535/2 ~= 32766
require Logger
batch_size = 5_000

placeholders = %{timestamp: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)}

# set the concurrency to match the max allowed pool size
db_config = Application.get_env(:rando, Rando.Repo)

Logger.debug("Started seeding the users table with pool_size #{db_config[:pool_size]}")
start_time = NaiveDateTime.utc_now()

Enum.to_list(0..999_999)
|> Stream.map(fn _ ->
  %{inserted_at: {:placeholder, :timestamp}, updated_at: {:placeholder, :timestamp}}
end)
|> Stream.chunk_every(batch_size)
|> Task.async_stream(
  fn users ->
    Rando.Repo.insert_all("users", users, placeholders: placeholders)
  end,
  max_concurrency: db_config[:pool_size],
  ordered: false
)
|> Enum.to_list()

end_time = NaiveDateTime.utc_now()
diff = Time.diff(end_time, start_time, :microsecond)

Logger.debug(
  "Completed seeding the users table in #{diff} microseconds #{diff / 1_000_000} seconds"
)

# Runs in <2s

# below are estimate time completions of the seeding, they only serve as a benchmark to guide
# the reasoning behind the batch_size as I was unable to fully figure out why the speeds
# were better for smaller batch sizes. So through trial and error I arrived on 5000, below
# is my empirical summary.
#
# batch_size = 10,000
# [debug] Completed seeding the users table in 3513949 microseconds 3.513949 seconds

# batch_size =  3500
# [debug] Completed seeding the users table in 1898847 microseconds 1.898847 seconds

# batch_size = 5000
# [debug] Completed seeding the users table in 1704929 microseconds 1.704929 seconds

# batch_size = 6000
# [debug] Completed seeding the users table in 2020233 microseconds 2.020233 seconds

# batch_size = 30000
# [debug] Completed seeding the users table in 3415448 microseconds 3.415448 seconds
