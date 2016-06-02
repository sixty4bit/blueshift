Blueshift.migration do
  up do
    puts "hello"
  end

  down do
    puts "goodbye"
  end

  redup do
    puts "red hello"
  end

  reddown do
    puts "red goodbye"
  end
end
