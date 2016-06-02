Blueshift.migration do
  up do
    puts "hello2"
  end

  down do
    puts "goodbye2"
  end

  redup do
    puts "red hello"
  end

  reddown do
    puts "red goodbye"
  end
end
