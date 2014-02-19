module Graphics
  class Ground
    def initialize(picture = "", position = Position.new(15, 2), width = 30, height = 25)
      @picture  = picture
      @position = position
      @width    = width
      @height   = height
    end

    def render_array
      render_result = Border.new(Position.new(@position.x - 1, @position.y - 1), Position.new(@position.x + @width + 1, @position.y + @height + 1)).render_array
      @height.times do |y_coordinate| 
        @width.times do |x_coordinate| 
          render_result += Image.new(@picture, Position.new(@position.x + x_coordinate, @position.y + y_coordinate)).render_array
        end
      end
      render_result
    end

    def picture_index_change(index, value)
      if value == 1 or value == 2 or value == 3
        if (value == 1 and @picture_indexes[index] == [2]) or 
           (value == 2 and @picture_indexes[index] == [1]) or 
           (value == 1 and @picture_indexes[index] == [2, 3])
          @picture_indexes[index] = [1, 2]
        else
          if (value == 2 and @picture_indexes[index] == [3]) or 
             (value == 3 and @picture_indexes[index] == [2]) or 
             (value == 3 and @picture_indexes[index] == [1, 2])
            @picture_indexes[index] = [2, 3]
          else
            @picture_indexes[index] = [value] unless @picture_indexes[index].size == 2
          end
        end
      else
        @picture_indexes[index] = [value]
      end
      value = 5 if @picture_indexes[index] == [1, 2]
      value = 6 if @picture_indexes[index] == [2, 3]
      @pictures[index].path = @picture_paths[value]
    end

    def set_pictures
      current_x, current_y = @position.x, @position.y
      @pictures.each_index do |index|
        @pictures[index].path = @picture_paths[@picture_indexes[index][0]]
        @pictures[index].move current_x, current_y
        current_x += @pictures[index].full_width
        if ((index + 1).remainder @width) == 0
          current_x  = @position.x
          current_y += @pictures[index].full_height
        end
      end
      draw_border
    end

    def picture_hover?(index, mouse_left, mouse_top)
      @pictures[index].style[:left] + @pictures[index].full_width > mouse_left and
      @pictures[index].style[:top] + @pictures[index].full_height > mouse_top
    end

    def picture_index_at(mouse_left, mouse_top)
      return false if !ground_hover? mouse_left, mouse_top
      @pictures.each_index do |index|
        return index if picture_hover? index, mouse_left, mouse_top
      end
    end

    def propriety_check
      warnings = ""
      warnings << "The level doesn't have a start." unless @picture_indexes.include? [3] or @picture_indexes.include? [2, 3]
      if (@picture_indexes.count([1]) != @picture_indexes.count([2]) and @picture_indexes.include?([2, 3]) == false) or
         ((@picture_indexes.count([1]) - 1) != @picture_indexes.count([2]) and @picture_indexes.include? [2, 3])
        warnings << " Cubes don't match the finals count."
      end
      warnings << " There are no cubes." if @picture_indexes.count([1]) == 0 and @picture_indexes.count([1, 2]) == 0
      warnings << " The level is already solved." if @picture_indexes.all? { |element| element != [1] } and warnings == ""
      warnings
    end

    def fix_start
      picture_index_change(@picture_indexes.index([3]), 4) if @picture_indexes.include? [3]
      if @picture_indexes.include? [2, 3]
        @pictures[@picture_indexes.index([2, 3])].path = @picture_paths[2]
        @picture_indexes[@picture_indexes.index([2, 3])] = [2]
      end
    end

    def update(left, top, tool_box)
      fix_start if tool_box.clicked_tool == 3
      picture_index_change picture_index_at(left, top), tool_box.clicked_tool
    end

    def clear
      @pictures.each_index { |index| picture_index_change index, 4 }
    end
  end
end