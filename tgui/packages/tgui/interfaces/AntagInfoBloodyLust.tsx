import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { Window } from '../layouts';

type Objective = {
  count: number;
  name: string;
  explanation: string;
}

type Info = {
  objectives: Objective[];
  goal: string;
};

export const AntagInfoBloodyLust = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    intro,
    goal,
    policy,
  } = data;
  return (
    <Window
      width={620}
      height={300}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Section scrollable fill>
              <Stack vertical>
                <Stack.Item textColor="red" fontSize="20px">
                  You are the Bloody Lust Addict.
                </Stack.Item>
                <Stack.Item>
                  Bloody Lust, and it&apos;s cursed victims. A horrific drug
                  even the most immoral dealer wouldn&apos;t stock, despite
                  its allure. It is said a Bloody Lust trip is unlike any
                  other, waves of primal euphoria crashing against the mind.
                  Your thrill seeking foolishly led to taking a dose, and your
                  foggy memories recollect how you tore through your friends,
                  ending the night on a pile of corpses. You still feel the
                  Bloody Lust in you, for it never leaves once taken. It is
                  rewiring your mind, reforming your body, all for one purpose:
                  To mindlessly kill.
                </Stack.Item>
                <Stack.Item>
                  <ObjectivePrintout />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          {!!policy && (
            <Stack.Item>
              <Section textAlign="center" textColor="red" fontSize="19px">
                {policy}
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ObjectivePrintout = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    objectives,
  } = data;
  return (
    <Stack vertical>
      <Stack.Item bold>
        Your goal:
      </Stack.Item>
      <Stack.Item>
        {!objectives && "None!"
        || objectives.map(objective => (
          <Stack.Item key={objective.count}>
            #{objective.count}: {objective.explanation}
          </Stack.Item>
        )) }
      </Stack.Item>
    </Stack>
  );
};
