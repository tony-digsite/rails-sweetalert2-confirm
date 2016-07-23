module RailsSweetAlert2Confirm
  SWAL_OPTIONS_MAPPINGS = {
    confirm: :title,
    remote:  :remote
  }

  module ViewHelpers
    def link_to(*args, &block)
      options = args[block_given? ? 1 : 2] || {}
      options = merge_options_into_swal(options)
      super(*args, &block)
    end

    def submit_tag(value = 'Save changes', options = {})
      options = merge_options_into_swal(options)
      super value, options
    end

    def button_tag(*args, &block)
      options = args[block_given? ? 0 : 1] || {}
      options = merge_options_into_swal(options)
      super(*args, &block)
    end

    protected

    def merge_options_into_swal(options)
      options = merge_confirm_into_swal(options)
      merge_remote_into_swal(options)
    end

    %w(confirm remote method).each do |option|
      define_method("merge_#{option}_into_swal") do |options|
        if send("options_has_#{option}?", options)
          options[:data] ||= {}
          options[:data][:swal] ||= {}
          option = option.to_sym
          options[:data][:swal][SWAL_OPTIONS_MAPPINGS[option]] =
            send("retrieve_#{option}_from", options)
        end
        options
      end

      define_method("retrieve_#{option}_from") do |options|
        case option
        when "method"
          options[option] || options[:data][option]
        else
          options.delete(option) || options[:data].delete(option)
        end
      end

      define_method("options_has_#{option}?") do |options|
        option = option.to_sym
        (options[option] || options[:data].try(:[], option)).present?
      end
    end
  end
end
