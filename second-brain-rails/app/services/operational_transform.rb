class OperationalTransform
  # Transform two concurrent operations
  def self.transform(op_a, op_b)
    return [op_a, op_b] if op_a.sequence_number == op_b.sequence_number
    
    case [op_a.interaction_type, op_b.interaction_type]
    when ['insert', 'insert'], ['keystroke', 'keystroke']
      transform_insert_insert(op_a, op_b)
      
    when ['insert', 'delete'], ['keystroke', 'delete']
      transform_insert_delete(op_a, op_b)
      
    when ['delete', 'insert'], ['delete', 'keystroke']
      transform_delete_insert(op_a, op_b)
      
    when ['delete', 'delete']
      transform_delete_delete(op_a, op_b)
      
    else
      [op_a, op_b]
    end
  end
  
  # Both inserted at (possibly) same position
  def self.transform_insert_insert(op_a, op_b)
    pos_a = op_a.position || 0
    pos_b = op_b.position || 0
    
    if pos_a < pos_b
      # A inserts before B, shift B right
      op_b.position = pos_b + (op_a.char&.length || 1)
    elsif pos_a > pos_b
      # B inserts before A, shift A right
      op_a.position = pos_a + (op_b.char&.length || 1)
    else
      # Same position - use sequence as tiebreaker
      if op_a.sequence_number < op_b.sequence_number
        op_b.position = pos_b + (op_a.char&.length || 1)
      else
        op_a.position = pos_a + (op_b.char&.length || 1)
      end
    end
    
    [op_a, op_b]
  end
  
  def self.transform_insert_delete(op_a, op_b)
    pos_a = op_a.position || 0
    pos_b = op_b.position || 0
    
    if pos_a <= pos_b
      # Insert before delete, shift delete right
      op_b.position = pos_b + (op_a.char&.length || 1)
    elsif pos_a > pos_b
      # Delete before insert, shift insert left
      op_a.position = [pos_a - 1, 0].max
    end
    
    [op_a, op_b]
  end
  
  def self.transform_delete_insert(op_a, op_b)
    # Mirror of insert_delete
    result = transform_insert_delete(op_b, op_a)
    [result[1], result[0]]
  end
  
  def self.transform_delete_delete(op_a, op_b)
    pos_a = op_a.position || 0
    pos_b = op_b.position || 0
    
    if pos_a == pos_b
      # Both delete same position - only one should apply
      # Keep the one with lower sequence
      if op_a.sequence_number < op_b.sequence_number
        op_b.interaction_type = 'noop'  # Cancel B
      else
        op_a.interaction_type = 'noop'  # Cancel A
      end
    elsif pos_a < pos_b
      # A deletes before B, shift B left
      op_b.position = pos_b - 1
    else
      # B deletes before A, shift A left
      op_a.position = pos_a - 1
    end
    
    [op_a, op_b]
  end
  
  # Merge concurrent timelines
  def self.merge_timelines(note_id, device_a, device_b, common_seq)
    ops_a = Interaction.where(note_id: note_id, device_id: device_a)
      .where('sequence_number > ?', common_seq)
      .ordered
      
    ops_b = Interaction.where(note_id: note_id, device_id: device_b)
      .where('sequence_number > ?', common_seq)
      .ordered
    
    # Transform all pairs of concurrent operations
    merged = []
    i = j = 0
    
    while i < ops_a.length || j < ops_b.length
      if i >= ops_a.length
        merged << ops_b[j]
        j += 1
      elsif j >= ops_b.length
        merged << ops_a[i]
        i += 1
      elsif ops_a[i].sequence_number < ops_b[j].sequence_number
        merged << ops_a[i]
        i += 1
      else
        merged << ops_b[j]
        j += 1
      end
    end
    
    merged
  end
end
