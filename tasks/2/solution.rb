class Hash
    def fetch_deep(path)
        keys = path.split('.')
        object = self
        keys.each { |key| object = next_object(object, key) }
        object
    end
    
    def reshape(shape)
        reshaped_hash = shape.deep? ? deep_reshape(shape) : shallow_reshape(shape)
        self.clear
        self.merge!(reshaped_hash)
    end
    def deep?
        self.values.any? { |value| value.is_a?(Hash) }
    end
    private
    def shallow_reshape(shape)
        reshaped_hash = {}
        shape.each { |key, value| reshaped_hash[key] = self.fetch_deep(value) }
        reshaped_hash
    end
    def deep_reshape(shape)
        reshaped = {}
        shape.each { |key, value| reshaped[key] = proper_hash_from_value(value) }
        reshaped
    end
    def proper_hash_from_value(value)
        return deep_reshape(value) if value.deep?
        shallow_reshape(value)
    end
    def next_object(object, key)
        return object[key.to_i] if object.is_a?(Array)
        object.fetch(key) { object.fetch(key.to_sym, nil) }
    end
end
class Array
    def reshape(shape)
        self.each { |hash| hash.reshape(shape) }   
    end
end
