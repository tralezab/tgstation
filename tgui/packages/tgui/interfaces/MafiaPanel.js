import { classes } from 'common/react';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Flex, Section, TimeDisplay } from '../components';
import { Window } from '../layouts';

export const MafiaPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    lobbydata,
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
  const readyGhosts = lobbydata ? lobbydata.filter(
    player => player.status === "Ready") : null;
  return (
    <Window
      title="Mafia"
      theme={role_theme}
      width={650}
      height={550}
      resizable>
      <Window.Content>
        {!roleinfo && (
          <Section
            title="Lobby"
            minHeight={8}
            buttons={
              <LobbyDisplay phase={phase} timeleft={timeleft} />
            }>
            <Box bold textAlign="center">
              The lobby currently has {readyGhosts.length}
              /12 valid players signed up.
              <Flex
                direction="column">
                {!!lobbydata && lobbydata.map(lobbyist => (
                  <Flex.Item
                    key={lobbyist}
                    basis={2}
                    className="Section__title candystripe">
                    <Flex
                      bold
                      height={2}
                      align="center"
                      justify="space-between">
                      <Flex.Item basis={0}>
                        {lobbyist.name}
                      </Flex.Item>
                      <Flex.Item>
                        STATUS:
                      </Flex.Item>
                      <Flex.Item width="30%">
                        <Section>
                          <Box
                            color={
                              lobbyist.status === "Ready" ? "green" : "red"
                            }
                            textAlign="center">
                            {lobbyist.status} {lobbyist.spectating}
                          </Box>
                        </Section>
                      </Flex.Item>
                    </Flex>
                  </Flex.Item>
                ))}
              </Flex>
            </Box>
          </Section>
        )}
        {!!roleinfo && (
          <Section
            title={phase}
            minHeight="100px"
            buttons={
              <Box>
                <TimeDisplay auto="down" value={timeleft} />
              </Box>
            }>
            <Flex
              justify="space-between">
              <Flex.Item
                align="center"
                textAlign="center"
                maxWidth="500px">
                <b>You are the {roleinfo.role}</b><br />
                <b>{roleinfo.desc}</b>
              </Flex.Item>
              <Flex.Item>
                <Box
                  className={classes([
                    'mafia32x32',
                    roleinfo.revealed_icon,
                  ])}
                  style={{
                    'transform': 'scale(2) translate(0px, 5px)',
                    'vertical-align': 'middle',
                  }} />
                <Box
                  className={classes([
                    'mafia32x32',
                    roleinfo.hud_icon,
                  ])}
                  style={{
                    'transform': 'scale(2) translate(-5px, -5px)',
                    'vertical-align': 'middle',
                  }} />
              </Flex.Item>
            </Flex>
          </Section>
        )}
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
            <Flex justify="center">
              <Button
                icon="meh"
                color="grey"
                onClick={() => act("vote_abstain")}>
                Abstain
              </Button>
            </Flex>
          </Section>
        )}
        {phase !== "No Game" &&(
          <Flex mt={1} spacing={1}>
            <Flex.Item grow={2} basis={0}>
              <Section title="Players">
                <Flex
                  direction="column">
                  {!!players && players.map(player => (
                    <Flex.Item
                      basis={2}
                      className="Section__title candystripe"
                      key={player.ref}>
                      <Flex
                        height={2}
                        justify="space-between"
                        align="center">
                        <Flex.Item basis={16} >
                          {!!player.alive && (<Box>{player.name}</Box>)}
                          {!player.alive && (
                            <Box color="red">{player.name}</Box>)}
                        </Flex.Item>
                        <Flex.Item>
                          {!player.alive && (<Box color="red">DEAD</Box>)}
                        </Flex.Item>
                        <Flex.Item>
                          {player.votes !== undefined && !!player.alive
                          && (<Fragment>Votes : {player.votes} </Fragment>)}
                        </Flex.Item>
                        <Flex.Item grow={1} />
                        <Flex.Item>
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
                        </Flex.Item>
                      </Flex>
                    </Flex.Item>)
                  )}
                </Flex>
              </Section>
            </Flex.Item>
            <Flex.Item grow={1} basis={0}>
              <Section
                title="Roles">
                <Flex
                  direction="column">
                  {!!all_roles && all_roles.map(r => (
                    <Flex.Item
                      key={r}
                      basis={2}
                      className="Section__title candystripe">
                      <Flex
                        height={2}
                        align="center"
                        justify="space-between">
                        <Flex.Item>
                          {r}
                        </Flex.Item>
                        <Flex.Item grow={1} />
                        <Flex.Item
                          textAlign="right">
                          <Button
                            content="?"
                            onClick={() => act("mf_lookup", {
                              atype: r.slice(0, -3),
                            })}
                          />
                        </Flex.Item>
                      </Flex>
                    </Flex.Item>
                  ))}
                </Flex>
              </Section>
            </Flex.Item>
          </Flex>
        )}
        {!!roleinfo && (
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
        )}

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

const LobbyDisplay = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    phase,
    timeleft,
  } = data;
  return (
    <Box bold>
      [Phase = {phase} | <TimeDisplay auto="down" value={timeleft} />]{' '}
      <Button content="Sign Up" onClick={() => act("mf_signup")} />
      <Button content="Spectate" onClick={() => act("mf_spectate")} />
    </Box>
  );
};
