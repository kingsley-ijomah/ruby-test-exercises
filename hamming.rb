class Hamming
 def self.compute(strand_1, strand_2)
 	raise ArgumentError unless strands_equal?(strand_1, strand_2)

 	strand_1.each_char.zip(strand_2.each_char).count {|a,b| a != b}
 end

 def self.strands_equal?(strand_1, strand_2)
 	strand_1.chars.count == strand_2.chars.count
 end
end