require 'tar/header'

class Tar::HeaderTest < Minitest::Test
  def test_true
    header = ::Tar::Header.new(
      name:  'a',
      mode:  0664,
      size:  06,
      mtime: 013130503124,
      uid:   01750,
      gid:   01750,
      uname: 'michael',
      gname: 'michael'
    )

    assert_equal(010775, header.checksum.to_i(8))
  end
end
