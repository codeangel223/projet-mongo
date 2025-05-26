rs.initiate({
  _id: "shard3",
  members: [
    { _id: 0, host: "shard3-1:27018" },
    { _id: 1, host: "shard3-2:27018" },
    { _id: 2, host: "shard3-3:27018" }
  ]
});
