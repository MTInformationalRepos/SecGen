require 'nokogiri'

# Convert systems objects into xml
class XMLReportGenerator

  # @param [Object] systems the list of systems
  # @param [Object] scenario the scenario file used to generate
  # @param [Object] time the current time as a string
  def initialize(systems, scenario, time)
    @systems = systems
    @scenario = scenario
    @time = time
  end

  # outputs a XML scenario file that can be used to replay these systems
  # any randomisation that has been applied should be un-randomised in this output (compared to the original scenario file)
  # @return [Object] xml string
  def output
    ns = {
      'xmlns' => "http://www.github/cliffe/SecGen/scenario",
      'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
      'xsi:schemaLocation' => "http://www.github/cliffe/SecGen/scenario"
    }
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.scenario (ns) {
        xml.comment 'This file was generated by SecGen'
        xml.comment "#{@time}"
        xml.comment "Based on a fulfilment of scenario: #{@scenario}"
        xml.comment 'You can replay the generation of these VM(s) using SecGen -s <this file> r'
        @systems.each { |system|
          xml.system {
            xml.system_name system.name
            system.module_selections.each { |selected_module|
              module_element(selected_module, xml)
            }
          }
        }
      }
    end
    builder.to_xml

  end

  def module_element(selected_module, xml)
    # don't include modules that write to others
    # (we just output the end result in terms of literal values)
    if selected_module.write_to_module_with_id != ''
      xml.comment "Used to calculate values: #{selected_module.module_path}"
      xml.comment "  (inputs: #{selected_module.received_inputs.inspect}, outputs: #{selected_module.output.inspect})"
      return
    end
    case selected_module.module_type
      # FIXME: repetition of logic :-(
      when 'vulnerability'
        xml.vulnerability(selected_module.attributes_for_scenario_output) {
          selected_module.received_inputs.each do |key,value|
            xml.input({"into" => key}) {
              xml.value value
            }
          end
        }
      when 'base'
        xml.base(selected_module.attributes_for_scenario_output) {
          selected_module.received_inputs.each do |key,value|
            xml.input({"into" => key}) {
              xml.value value
            }
          end
        }
      when 'build'
        xml.build(selected_module.attributes_for_scenario_output) {
          selected_module.received_inputs.each do |key,value|
            xml.input({"into" => key}) {
              xml.value value
            }
          end
        }
      when 'service'
        xml.service(selected_module.attributes_for_scenario_output) {
          selected_module.received_inputs.each do |key,value|
            xml.input({"into" => key}) {
              xml.value value
            }
          end
        }
      when 'utility'
        xml.utility(selected_module.attributes_for_scenario_output) {
          selected_module.received_inputs.each do |key,value|
            xml.input({"into" => key}) {
              xml.value value
            }
          end
        }
      when 'forensic'
        xml.forensic(selected_module.attributes_for_scenario_output) {
          selected_module.received_inputs.each do |key,value|
            xml.input({"into" => key}) {
              xml.value value
            }
          end
        }
      when 'network'
        xml.network(selected_module.attributes_for_scenario_output)
      else
        puts "Unexpected module type: #{selected_module.attributes_for_scenario_output}"
        exit
    end
  end
end
