# frozen_string_literal: true

module Kml
  module Path
    class Result
      attr_reader :name, :coordinates, :error

      def initialize(success:, name:, coordinates:, error:)
        @success = success
        @name = name
        @coordinates = coordinates
        @error = error
      end

      def success?
        @success
      end

      def failure?
        !success?
      end
    end
  end
end
