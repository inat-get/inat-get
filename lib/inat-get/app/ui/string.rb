# frozen_string_literal: true

class String

  ANSI  = /\e\[[0-9;]*[a-zA-Z]/
  EMOJI = /\p{Emoji_Presentation}/
  EAST  = /\p{Han}|\p{Hiragana}|\p{Katakana}|\p{Hangul}/

  def width
    current = 0
    self.scan(/#{ ANSI }|\X/) do |match|
      w = case match
      when ANSI
        0
      when EMOJI, EAST
        2
      else
        1
      end
      current += w
    end
    current
  end

  def truncate width
    return self if self.length <= width
    current = 0
    position = 0
    self.scan(/#{ ANSI }|\X/) do |match|
      w = case match
      when ANSI
        0
      when EMOJI, EAST
        2
      else
        1
      end
      current += w
      return self[0, position] if current > width
      position += match.length
    end
    return self
  end

end
