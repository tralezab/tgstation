import { BooleanLike } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dimmer, Icon, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';

const dimmed = '#111111';

const CATEGORY2ICON = {
  'Custom': 'pencil',
  'Abductor': 'brain',
  'Other': 'ellipsis',
  'Biohazards': 'biohazard',
  'Brother': 'user-group',
  'Changeling': 'teeth',
  'Cult': 'hands-praying',
  'Uncategorized': 'exclamation',
  'Heretic': 'eye',
  'Malf AI': 'robot',
  'NukeOp': 'bomb',
  'ClownOp': 'face-grin-squint-tears',
  'Revolution': 'hand-fist',
  'Space Dragon': 'dragon',
  'Space Ninja': 'user-ninja',
  'Traitor': 'user-secret',
  'Wizard': 'hat-wizard',
};

export const TraitorPanel = (props, context) => {
  const { data } = useBackend<{ mind: BooleanLike }>(context);
  const { mind } = data;

  return (
    <Window theme="admin" title="Traitor Panel" width={500} height={600}>
      <Window.Content>
        {!mind ? (
          <Dimmer fontSize="30px" textAlign="center">
            <Icon fontSize="60px" name="brain" color="red" />
            <br />
            Lost connection to mind...
          </Dimmer>
        ) : (
          <Stack fill vertical>
            <Stack.Item>
              <MindProfile />
            </Stack.Item>
            <Stack.Item grow>
              <AntagonistList />
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};

type MindProfileData = {
  mindName: string;
  realName: string;
  mindKey: string;
  keyActive: BooleanLike;
  assignedRole: string;
  specialRole?: string;
  specialStatuses: SpecialStatus[];
};

type SpecialStatus = {
  content: string;
  positive: BooleanLike;
  icon: string;
};

export const MindProfile = (props, context) => {
  const { data } = useBackend<MindProfileData>(context);
  const { mindName, realName, mindKey, keyActive, assignedRole, specialRole } =
    data;

  // const [announce, setAnnounce] = useLocalState(context, 'announce', true);

  const profileTitle = mindName + (realName ? ` (as ${realName})` : '');

  return (
    <Section title={profileTitle} fill>
      <Stack vertical>
        <Stack.Item>
          Mind played by key{' '}
          <Box inline color="green">
            {mindKey}
          </Box>{' '}
          {keyActive ? (
            <Box inline color="green">
              (synced)
            </Box>
          ) : (
            <Box inline color="red">
              (not synced)
            </Box>
          )}
        </Stack.Item>
        <Stack.Item>Assigned role: {assignedRole}</Stack.Item>{' '}
        {specialRole ? `Special role: ${specialRole}` : ''}
        <Stack.Item>
          <SpecialStatuses />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const SpecialStatuses = (props, context) => {
  const { data } = useBackend<MindProfileData>(context);
  const { specialStatuses } = data;

  return (
    <Stack>
      <Stack.Item>
        Special Statuses: {!specialStatuses.length && 'None!'}
      </Stack.Item>
      {specialStatuses.map((status, index) => (
        <Stack.Item color={status.positive ? 'green' : 'red'} key={index}>
          {status.content} <Icon name={status.icon} />
        </Stack.Item>
      ))}
    </Stack>
  );
};

type Antagonist = {
  name: string;
  type: string;
  category: string;
  hasThis?: BooleanLike;
};

type AntagonistListData = {
  antagonistCategories: string[];
  antagonists: Antagonist[];
};

export const AntagonistList = (props, context) => {
  const { data } = useBackend<AntagonistListData>(context);
  const { antagonists, antagonistCategories } = data;

  const [category, setCategory] = useLocalState(
    context,
    'category',
    antagonistCategories[0]
  );

  const filteredAntags = antagonists.filter((antag) => {
    return antag.category === category;
  });

  return (
    <Section fill title="Antagonists">
      <Stack>
        <Stack.Item grow>
          <Tabs vertical>
            {antagonistCategories.map((cat, index) => (
              <Tabs.Tab
                icon={CATEGORY2ICON[cat] || 'dragon'}
                onClick={() => setCategory(cat)}
                selected={category === cat}
                key={index}>
                {cat}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow={2}>
          <Stack vertical fill>
            {filteredAntags.map((antag, i) => (
              <Stack.Item key={i}>
                <Section
                  title={antag.name}
                  buttons={
                    <Button color={antag.hasThis && 'green'}>
                      {antag.hasThis ? 'Disable' : 'Enable'}
                    </Button>
                  }
                  fitted
                  mx={1}
                  my={0.5}
                  pb="-300px"
                  backgroundColor="rgba(0, 0, 0, 0.4)"
                />
              </Stack.Item>
            ))}
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
