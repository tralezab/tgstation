import { paginate } from 'common/collections';
import { BooleanLike } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dimmer, Icon, Input, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';

const FACTION2ICON = {
  'Custom': 'pencil',
  'Syndicate': 'user-secret',
  'Magical': 'wand-magic-sparkles',
  'Creature': 'dragon',
  'Aliens': 'spaghetti-monster-flying',
  'Biohazards': 'biohazard',
  'Third Party': 'ellipsis',
};

const PURPOSE2ICON = {
  'Custom': 'pencil',
  'Solo Roles': 'user',
  'Supported Roles': 'user-group',
  'Team Roles': 'users',
  'Conversion Roles': 'user-plus',
};

const CATEGORIZATION_OPTIONS = [
  FACTION2ICON,
  PURPOSE2ICON,
  {}, // ALL
];

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
  hasThis?: BooleanLike;
};

type AntagonistGroup = {
  name: string;
  categories: string[];
  antagonists: Antagonist[];
};

type AntagonistListData = {
  allCategories: string[];
  allGroups: AntagonistGroup[];
};

export const AntagonistList = (props, context) => {
  const { data } = useBackend<AntagonistListData>(context);
  const { allGroups, allCategories } = data;
  const [categorizeSetting, setCategorizeSetting] = useLocalState<0 | 1 | 2>(
    context,
    'categorizeSetting',
    0
  );
  const cat2icon = CATEGORIZATION_OPTIONS[categorizeSetting];
  const [category, setCategory] = useLocalState(context, 'category', 'Custom');
  const [searchQuery, setSearchQuery] = useLocalState(
    context,
    'searchQuery',
    ''
  );
  const categories = allCategories.filter((cat) => {
    return cat2icon[cat];
  });

  const showTabs = categorizeSetting !== 2 && !searchQuery;

  const antagonistGroups = paginate(
    allGroups.filter((antagGroup) => {
      if (!searchQuery) {
        if (categorizeSetting === 2) {
          return true;
        }
        return antagGroup.categories.includes(category);
      }
      // antag name search check
      if (antagGroup.name.toLowerCase().includes(searchQuery)) {
        return true;
      }
      // antag subcategory search check
      for (const antag of antagGroup.antagonists) {
        if (antag.name.toLowerCase().includes(searchQuery)) {
          return true;
        }
      }
      return false;
    }),
    !showTabs ? 2 : 1
  );

  const handleCategorizeChange = (newSetting: 0 | 1 | 2) => {
    setCategorizeSetting(newSetting);
    setCategory('Custom');
  };

  return (
    <Section scrollable fill>
      <Box m="-6px" mb={1} className="Section__title Section--scrollable">
        <Stack>
          <Stack.Item>
            <Button
              style={{
                'border-top-right-radius': '0',
                'border-bottom-right-radius': '0',
              }}
              mr="-1px"
              selected={categorizeSetting === 0}
              onClick={() => handleCategorizeChange(0)}>
              Factions
            </Button>
            <Button
              style={{
                'border-radius': '0',
              }}
              mr="0px"
              selected={categorizeSetting === 1}
              onClick={() => handleCategorizeChange(1)}>
              Roles
            </Button>
            <Button
              style={{
                'border-top-left-radius': '0',
                'border-bottom-left-radius': '0',
              }}
              selected={categorizeSetting === 2}
              onClick={() => handleCategorizeChange(2)}>
              All
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Input
              fluid
              onInput={(e) => setSearchQuery(e.target.value)}
              placeholder="Search for an Antagonist..."
              value={searchQuery}
            />
          </Stack.Item>
        </Stack>
      </Box>
      <Stack>
        {showTabs && (
          <>
            <Stack.Item grow>
              <Tabs vertical>
                {categories.map((cat, index) => (
                  <Tabs.Tab
                    icon={cat2icon[cat] || 'dragon'}
                    onClick={() => setCategory(cat)}
                    selected={category === cat}
                    key={index}>
                    {cat}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Stack.Item>
            <Stack.Divider />
          </>
        )}
        <Stack.Item grow={2}>
          <Stack vertical fill>
            {antagonistGroups.map((page, i) => (
              <Stack.Item key={i}>
                <Stack fill>
                  {page.map((antagGroup, j) => (
                    <AntagGroup key={j} group={antagGroup} />
                  ))}
                </Stack>
              </Stack.Item>
            ))}
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const AntagGroup = (props: { group: AntagonistGroup }, context) => {
  const { group } = props;
  const { name, antagonists } = group;

  return (
    <Stack.Item grow>
      <Section
        fill
        title={name}
        fitted
        mx={1}
        my={0.5}
        pb="-300px"
        backgroundColor="rgba(0, 0, 0, 0.4)">
        <Box p={1}>
          {antagonists.map((antag) => (
            <Button key={antag.type} tooltip={antag.type}>
              {antag.name}
            </Button>
          ))}
        </Box>
      </Section>
    </Stack.Item>
  );
};
