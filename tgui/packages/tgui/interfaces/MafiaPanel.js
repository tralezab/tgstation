import { classes } from 'common/react';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Flex, LabeledList, Section, TimeDisplay } from '../components';
import { Window } from '../layouts';

export const MafiaPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    players,
    actions,
    phase,
    roleinfo,
    role_theme,
    admin_controls,
    judgement_phase,
    timeleft,
    all_roles,
  } = data;
  return (
    <Window
      title="Mafia"
      theme={role_theme}
      width={650}
      height={550}
      resizable>
      <Window.Content>
        <Section
          title={phase}
          buttons={
            <Box>
              <TimeDisplay auto="down" value={timeleft} />
            </Box>
          }>
          {!!roleinfo && (
            <Fragment>
              <Flex justify="center">
                <b>You are the {roleinfo.role}</b>
              </Flex>
              <Flex
                justify="space-between">
                <Flex.Item>
                  <Box
                    className={classes([
                      'mafia32x32',
                      roleinfo.hud_icon,
                    ])}
                    style={{
                      'transform': 'scale(4)',
                      '-ms-interpolation-mode': 'nearest-neighbor',
                      'vertical-align': 'middle',
                    }} />
                </Flex.Item>
                <Flex.Item align="center" textAlign="center">
                  <b>{roleinfo.desc}</b>
                </Flex.Item>
                <Flex.Item>
                  <Box
                    className={classes([
                      'mafia32x32',
                      roleinfo.revealed_icon,
                    ])}
                    style={{
                      'transform': 'scale(2) translate(0%, 0%)',
                      '-ms-interpolation-mode': 'nearest-neighbor',
                      'vertical-align': 'middle',
                    }} />
                </Flex.Item>
              </Flex>
            </Fragment>
          )}
        </Section>
        <Flex>
          {!!actions && actions.map(action => (
            <Flex.Item key={action}>
              <Button
                onClick={() => act("mf_action", { atype: action })}>
                {action}
              </Button>
            </Flex.Item>
          ))}
        </Flex>
        {!!judgement_phase && (
          <Section title="JUDGEMENT">
            <Flex justify="space-around">
              <Button
                icon="smile-beam"
                color="good"
                onClick={() => act("vote_innocent")}>
                INNOCENT!
              </Button>
              Use these buttons to vote the accused innocent or guilty!
              <Button
                icon="angry"
                color="bad"
                onClick={() => act("vote_guilty")}>
                GUILTY!
              </Button>
            </Flex>
          </Section>
        )}
        <Flex mt={1} spacing={1}>
          <Flex.Item grow={2} basis={0}>
            <Section title="Players">
              <LabeledList>
                {!!players && players.map(player => (
                  <LabeledList.Item
                    className="Section__title candystripe"
                    key={player.ref}
                    label={player.name}
                    labelColor={player.alive ? "label" : "red"}
                    textAlign="center">
                    {!player.alive && (<Box color="red">DEAD</Box>)}
                    {player.votes !== undefined && !!player.alive
                    && (<Fragment>Votes : {player.votes} </Fragment>)}
                    {
                      !!player.actions && player.actions.map(action => {
                        return (
                          <Button
                            key={action}
                            onClick={() => act('mf_targ_action', {
                              atype: action,
                              target: player.ref,
                            })}>
                            {action}
                          </Button>); })
                    }
                  </LabeledList.Item>)
                )}
              </LabeledList>
            </Section>
          </Flex.Item>
          <Flex.Item grow={1} basis={0}>
            <Section
              title="Roles">
              {!!all_roles && all_roles.map(r => (
                <Box key={r}>
                  <Flex justify="space-between">
                    {r}
                    <Button
                      content="?"
                      onClick={() => act("mf_lookup", {
                        atype: r.slice(0, -3),
                      })}
                    />
                  </Flex>
                </Box>
              ))}
            </Section>
          </Flex.Item>
        </Flex>
        <Flex mt={1} spacing={1}>

          <Flex.Item grow={2} basis={0}>
            <Section
              title="Notes"
              minHeight={10}>
              {roleinfo !== undefined && !!roleinfo.action_log
              && roleinfo.action_log.map(log_line => (
                <Box key={log_line}>
                  {log_line}
                </Box>
              ))}
            </Section>
          </Flex.Item>
        </Flex>
        {!!admin_controls && (
          <Section
            title="ADMIN CONTROLS"
            backgroundColor="red">
            THESE ARE DEBUG, THEY WILL BREAK THE GAME, DO NOT TOUCH <br />
            Also because an admin did it: do not gib/delete/etc
            anyone! It will runtime the game to death! <br />
            <Button
              icon="arrow-right"
              onClick={() => act("next_phase")}>
              Next Phase
            </Button>
            <Button
              icon="home"
              onClick={() => act("players_home")}>
              Send All Players Home
            </Button>
            <Button
              icon="radiation"
              onClick={() => act("new_game")}>
              New Game
            </Button>
            <br />
            This makes the next game what you input.
            Resets after one round automatically.
            <br />
            <Button
              icon="exclamation-circle"
              onClick={() => act("debug_setup")}>
              Create Custom Setup
            </Button>
            <Button
              icon="arrow-left"
              onClick={() => act("cancel_setup")}>
              Reset Custom Setup
            </Button>
            <br />
            <Button
              icon="skull"
              onClick={() => act("nuke")}
              color="black">
              Nuke (delete datum + landmarks, hope it fixes everything!)
            </Button>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
