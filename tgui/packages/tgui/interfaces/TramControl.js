import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dimmer, Divider, Dropdown, Icon, LabeledList, Section, Stack } from '../components';
import { Window } from '../layouts';

const DEPARTMENT2COLOR = {
  Arrivals:"black",
  Service:"olive",
  Command:"blue",
  Security:"red",
  Medical:"teal",
  Engineering:"yellow",
  Cargo:"brown",
  Departures:"white",
};

const COLOR2BLURB = {
  blue:"This is the tram's current location.",
  green:"This is the selected destination.",
  transparent:"Click to set destination.",
};

const getDestColor = (dest, current_loc, transitIndex, destinations) => {
  return current_loc ? dest.name == current_loc[0].name ? "blue" : transitIndex == destinations.indexOf(dest) ? "green" : "transparent" : "bad";
};

const marginNormal = 1;
const marginDipped = 3;

const dipUnderCircle = (dest, dep) => {
  return Object.keys(dest.dest_icons).indexOf(dep) == 1 ? marginDipped :
  Object.keys(dest.dest_icons).indexOf(dep) == 2 ? marginDipped : marginNormal
};

const BrokenTramDimmer = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Dimmer>
      <Stack vertical>
        <Stack.Item>
          <Icon
            ml={7}
            color="red"
            name="exclamation"
            size={10}
          />
        </Stack.Item>
        <Stack.Item fontSize="14px" color="red">
          No Tram Detected!
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const MovingTramDimmer = (props, context) => {
  const { act, data } = useBackend(context);
  const { current_loc } = data;
  return (
    <Dimmer>
      <Stack vertical>
        <Stack.Item>
          <Icon
            ml={10}
            name="sync-alt"
            color="green"
            size={11}
          />
        </Stack.Item>
        <Stack.Item mt={5} fontSize="14px" color="green">
          The tram is travelling to {current_loc[0].name}!
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

export const TramControl = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    broken,
    moving,
    destinations,
  } = data;
  const current_loc = (destinations ? destinations.filter(
    dest => dest.here === 1) : null);
  const [
    transitIndex,
    setTransitIndex,
  ] = useLocalState(context, 'transit-index', 1);
  return (
    <Window
      title="Tram Controls"
      width={600}
      height={300}>
      <Window.Content>
        {!!broken && (
          <BrokenTramDimmer />
        )}
        {!!moving && (
          <MovingTramDimmer />
        )}
        <Section fill>
          <Stack vertical fill>
            <Stack.Item grow fontSize="16px" mt={1} mb={9} textAlign="center" grow>
              Nanotrasen Transit System
            </Stack.Item>
            <Stack.Item mb={4}>
              <Stack fill>
                <Stack.Item grow={2} />
                {destinations.map(dest => (
                  <Stack.Item key={dest.name} grow={1} >
                    <Stack vertical>
                      <Stack.Item  ml={5}>
                        <Button
                          mr={4.38}
                          color={getDestColor(dest, current_loc, transitIndex, destinations)}
                          circular
                          compact
                          height={5}
                          width={5}
                          tooltipPosition="top"
                          tooltip={COLOR2BLURB[getDestColor(dest, current_loc, transitIndex, destinations)]}
                          onClick={() => setTransitIndex(destinations.indexOf(dest))} >
                        <Icon ml={-2.1} mt={0.55} fontSize="60px" name="circle-o" />
                        </Button>
                        {destinations.length-1 != destinations.indexOf(dest) && (
                          <Section title=" " mt={-7.3} ml={10} mr={-6.1} />
                        ) || (
                          <Box mt={-2.3} />
                        )}
                      </Stack.Item>
                      {dest.dest_icons && (
                        <Stack.Item >
                          <Stack>
                            {Object.keys(dest.dest_icons).map(dep => (
                              <Stack.Item key={dep}
                                mt={dipUnderCircle(dest, dep)}>
                                <Button
                                  color={DEPARTMENT2COLOR[dep]}
                                  icon={dest.dest_icons[dep]}
                                  tooltipPosition="bottom"
                                  tooltip={dep}
                                  style={{
                                    'border-radius': '5em',
                                    'border': '2px solid white',
                                  }}
                                  />
                              </Stack.Item>
                            ))}
                          </Stack>
                        </Stack.Item>
                      )}
                    </Stack>
                  </Stack.Item>
                ))}
                <Stack.Item grow={1} />
              </Stack>
            </Stack.Item>
            <Stack.Item fontSize="16px" mt={1} mb={9} textAlign="center" grow>
              <Button
                disabled={current_loc.name == destinations[transitIndex].name}
                content="Send Tram"
                onClick={() => act('send', {
                  destIndex: transitIndex,
                })} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
