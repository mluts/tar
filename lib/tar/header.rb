# struct header_posix_ustar {
#         char name[100]
#         char mode[8]
#         char uid[8]
#         char gid[8]
#         char size[12]
#         char mtime[12]
#         char checksum[8]
#         char typeflag[1]
#         char linkname[100]
#         char magic[6]
#         char version[2]
#         char uname[32]
#         char gname[32]
#         char devmajor[8]
#         char devminor[8]
#         char prefix[155]
#         char pad[12]
# }

module Tar
  class Header
    Field = Struct.new(:key, :pack_template, :format_template, :default) do
      def format(value)
        if value && format_template
          Kernel.format(format_template, value)
        else
          value
        end
      end
    end

    FIELDS = [
      Field.new(:name,      'a100', '%s'),
      Field.new(:mode,      'a8',   '%07o', 0644),
      Field.new(:uid,       'a8',   '%07o', Process::Sys.getuid),
      Field.new(:gid,       'a8',   '%07o', Process::Sys.getgid),
      Field.new(:size,      'a12',  '%011o', 0),
      Field.new(:mtime,     'a12',  '%011o', 0),
      Field.new(:checksum,  'a8',   nil, ' ' * 7),
      Field.new(:linkflag,  'a1',   '%s', '0'),
      Field.new(:linkname,  'a100', '%s', "\0" * 100),
      Field.new(:magic,     'a6',   '%s', 'ustar'),
      Field.new(:version,   'a2',   '%s', '00'),
      Field.new(:uname,     'a32',  '%s', "\0" * 8),
      Field.new(:gname,     'a32',  '%s', "\0" * 8),
      Field.new(:devmajor,  'a8',   '%s', "\0" * 8),
      Field.new(:devminor,  'a8',   '%s', "\0" * 8),
      Field.new(:prefix,    'a155', '%s', "\0" * 155),
      Field.new(:pad,       'a12',  '%s', "\0" * 12)
    ].freeze

    include Enumerable

    def initialize(data = {})
      @data = data
    end

    def each
      FIELDS.each do |field|
        yield field, @data.fetch(field.key, field.default)
      end
    end

    def pack
      formatted_values.pack(pack_template)
    end

    def checksum
      @checksum ||= calculate_checksum
    end

    private

    def pack_template
      @pack_template ||= FIELDS.map(&:pack_template).join
    end

    def calculate_checksum
      sum = formatted_values.pack(pack_template).each_byte.reduce(0, :+)
      format('%06o ', sum)
    end

    def formatted_values
      @formatted_values ||= map { |field, value| field.format(value) }
    end
  end
end
