# Use python templating
from string import Template

# Capacitance on the buffer to be added
BUFCAP = 0.00228641 # pF

# Pin list
inputs = "aclk, bl_en, bleed_en, bsl_dac_config, bsl_dac_en, clamp_ref, di, man, read_dac_config, read_dac_en, read_ref, rram_addr, sa_clk, sa_en, set_rst, sl_en, we, wl_dac_config, wl_dac_en, wl_en".split(", ")
outputs = "sa_do, sa_rdy".split(", ")
pintypes = {i : "input" for i in inputs}
pintypes.update({o : "output" for o in outputs})

# Pin dictionary
pinlist = {}

# Use extracted wire capacitance values for each pin (without buffer) and add buffer cap
with open("pexcaps.txt") as pcfile:
  # Populate pin text
  for line in pcfile.readlines()[1:]:
    # Extract pin name and pin capacitance
    fields = line.split()
    pin, cap = fields[0], str(float(fields[-1])*1e12 + BUFCAP)
    try:
      pintop, index = pin.split("<")
      index = int(index.split(">")[0])
    except ValueError:
      pintop = pin
      index = 0

    # Create pin list
    if pintop in pinlist:
      pinlist[pintop][index] = cap
    else:
      pinlist[pintop] = {index : cap}

# Initialize pin text
pintext = ""

for pintop, pins in sorted(pinlist.items()):
  # For bus
  if len(pins) > 1:
    # Make a bus
    pintext += f"""
    bus({pintop}) {{
      bus_type : {pintop} ;
      direction : {pintypes[pintop]} ;"""

    # Special pintops
    if pintop == "di":
      pintext += """
      memory_write() { 
        address : rram_addr ;
        clocked_on : aclk ; 
      }"""
    if pintop == "sa_do":
      pintext += """
      memory_read() { 
        address : rram_addr ;
      }
      timing(){ 
        timing_sense : non_unate; 
        related_pin : "sa_clk"; 
        timing_type : rising_edge; 
        cell_rise(scalar) {
          values("4.000");
        }
        cell_fall(scalar) {
          values("4.000");
        }
        rise_transition(scalar) {
          values("0.075");
        }
        fall_transition(scalar) {
          values("0.075");
        }
      }"""

    # Add each pin and its cap to pintext
    for index, cap in sorted(pins.items()):
      pintext += f"""
      pin({pintop}[{index}]) {{
        capacitance : {cap} ;
      }}"""

    # Close off
    pintext += """
    }"""
  # For non-bus
  else:
    # Add each pin and its cap to pintext
    pintext += f"""
    pin({pintop}) {{
      direction : {pintypes[pintop]} ;
      capacitance : {pins[0]} ;
    """
    if pintop == "sa_rdy":
      pintext += """  timing(){ 
        timing_sense : non_unate; 
        related_pin : "sa_clk"; 
        timing_type : rising_edge; 
        cell_rise(scalar) {
          values("4.000");
        }
        cell_fall(scalar) {
          values("4.000");
        }
        rise_transition(scalar) {
          values("0.075");
        }
        fall_transition(scalar) {
          values("0.075");
        }
      }
    """
    pintext += f"""}}"""

# Insert into Liberty file template
with open("analog_rram.tmpl.lib") as libinfile, open("analog_rram.lib", "w") as outlibfile:
  t = Template(libinfile.read())
  libtext = t.substitute({"pintext": pintext.strip()})
  outlibfile.write(libtext)
