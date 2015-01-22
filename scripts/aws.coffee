# Description:
#   EC2 Controler.
#
# Notes:
#

module.exports = (robot) ->

  AWS = require('aws-sdk');
  AWS.config.accessKeyId = process.env.AWS_ACCESS_KEY_ID
  AWS.config.secretAccessKey = process.env.AWS_SECRET_ACCESS_KEY
  AWS.config.region = process.env.AWS_REGION

  robot.respond /ec2 ls( .*)?$/i, (msg) ->
    ec2 = new AWS.EC2({apiVersion: '2014-10-01'})
    ec2.describeInstances null, (err, res)->
      if err
        msg.send "Error: #{err}"
      else
        target = (msg.match[1] || '').trim()

        for data in res.Reservations
          ins = data.Instances[0]
          name = '[NoName]'
          id = ins.InstanceId

          for tag in ins.Tags when tag.Key is 'Name'
            name = tag.Value

          if !target
            msg.send "#{ins.InstanceId} #{name} #{ins.State.Name}"

          else if target in [id, name]
            msg.send "#{ins.InstanceId} #{name} #{ins.State.Name}"
            return


  robot.respond /ec2 start( .*)?$/i, (msg) ->
    ec2 = new AWS.EC2({apiVersion: '2014-10-01'})
    target = (msg.match[1] || '').trim()

    if !target
      return

    ec2.describeInstances null, (err, res)->
      if err
        msg.send "Error: #{err}"
      else
        for data in res.Reservations
          ins = data.Instances[0]
          for tag in ins.Tags when tag.Key is 'Name'
            name = tag.Value
          if name is target
            params =
              InstanceIds: [ins.InstanceId]
              DryRun: false

            ec2.startInstances params, (err, res) ->
              if err
                msg.send "Error: #{err}"
              else
                msg.send "START #{target} (#{ins.InstanceId})"
            return

        msg.send "#{target}: not found"


  robot.respond /ec2 stop( .*)?$/i, (msg) ->
    ec2 = new AWS.EC2({apiVersion: '2014-10-01'})
    target = (msg.match[1] || '').trim()

    if !target
      return

    ec2.describeInstances null, (err, res)->
      if err
        msg.send "Error: #{err}"
      else
        for data in res.Reservations
          ins = data.Instances[0]
          for tag in ins.Tags when tag.Key is 'Name'
            name = tag.Value
          if name is target
            params =
              InstanceIds: [ins.InstanceId]
              DryRun: false

            ec2.stopInstances params, (err, res) ->
              if err
                msg.send "Error: #{err}"
              else
                msg.send "STOP #{target} (#{ins.InstanceId})"
            return

        msg.send "#{target}: not found"

  # robot.hear /badger/i, (msg) ->
  #   msg.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"
  #
  # robot.respond /open the (.*) doors/i, (msg) ->
  #   doorType = msg.match[1]
  #   if doorType is "pod bay"
  #     msg.reply "I'm afraid I can't let you do that."
  #   else
  #     msg.reply "Opening #{doorType} doors"
  #
  # robot.hear /I like pie/i, (msg) ->
  #   msg.emote "makes a freshly baked pie"
  #
  # lulz = ['lol', 'rofl', 'lmao']
  #
  # robot.respond /lulz/i, (msg) ->
  #   msg.send msg.random lulz
  #
  # robot.topic (msg) ->
  #   msg.send "#{msg.message.text}? That's a Paddlin'"
  #
  #
  # enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
  # leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
  #
  # robot.enter (msg) ->
  #   msg.send msg.random enterReplies
  # robot.leave (msg) ->
  #   msg.send msg.random leaveReplies
  #
  # answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
  #
  # robot.respond /what is the answer to the ultimate question of life/, (msg) ->
  #   unless answer?
  #     msg.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
  #     return
  #   msg.send "#{answer}, but what is the question?"
  #
  # robot.respond /you are a little slow/, (msg) ->
  #   setTimeout () ->
  #     msg.send "Who you calling 'slow'?"
  #   , 60 * 1000
  #
  # annoyIntervalId = null
  #
  # robot.respond /annoy me/, (msg) ->
  #   if annoyIntervalId
  #     msg.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #     return
  #
  #   msg.send "Hey, want to hear the most annoying sound in the world?"
  #   annoyIntervalId = setInterval () ->
  #     msg.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #   , 1000
  #
  # robot.respond /unannoy me/, (msg) ->
  #   if annoyIntervalId
  #     msg.send "GUYS, GUYS, GUYS!"
  #     clearInterval(annoyIntervalId)
  #     annoyIntervalId = null
  #   else
  #     msg.send "Not annoying you right now, am I?"
  #
  #
  # robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
  #   room   = req.params.room
  #   data   = JSON.parse req.body.payload
  #   secret = data.secret
  #
  #   robot.messageRoom room, "I have a secret: #{secret}"
  #
  #   res.send 'OK'
  #
  # robot.error (err, msg) ->
  #   robot.logger.error "DOES NOT COMPUTE"
  #
  #   if msg?
  #     msg.reply "DOES NOT COMPUTE"
  #
  # robot.respond /have a soda/i, (msg) ->
  #   # Get number of sodas had (coerced to a number).
  #   sodasHad = robot.brain.get('totalSodas') * 1 or 0
  #
  #   if sodasHad > 4
  #     msg.reply "I'm too fizzy.."
  #
  #   else
  #     msg.reply 'Sure!'
  #
  #     robot.brain.set 'totalSodas', sodasHad+1
  #
  # robot.respond /sleep it off/i, (msg) ->
  #   robot.brain.set 'totalSodas', 0
  #   robot.respond 'zzzzz'
