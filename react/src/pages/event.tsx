import {
  BlockTitle,
  f7,
  List,
  ListItem,
  Navbar,
  Page,
  Toolbar,
} from 'framework7-react'
import { useEffect, type FC } from 'react'
import {
  actions as backendActions,
  selectors as backendSelectors,
} from '../reducers/backend'
import { useDispatch, useSelector } from 'react-redux'
import { EmptyFight, type Fight } from '../models/fight'
import { useTranslation } from 'react-i18next'
import type { Dispatch } from '@reduxjs/toolkit'
import { EmptyEvent, type Event } from '../models/event'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import {
  faCalendar,
  faClock,
  faLocation,
  faMap,
  faPersonChalkboard,
  faWeight,
} from '@fortawesome/free-solid-svg-icons'
import { DateUtils } from '../utils/date-utils'
import { Faker } from '../utils/faker'
import { Logger } from '../utils/logger'

const logger: Logger = new Logger('/src/pages/event.tsx')

type EventPageProps = {
  id: string
}

export const EventPage: FC<EventPageProps> = (props: EventPageProps) => {
  const { t } = useTranslation()
  const dispatch: Dispatch = useDispatch()

  const event: Event | undefined = useSelector(backendSelectors.getEvent)
  const fights: Fight[] = useSelector(backendSelectors.getFights)
  const error: Error | undefined = useSelector(backendSelectors.getError)
  const state: string = useSelector(backendSelectors.getState)

  const onPullRefreshed = async (done: () => void) => {
    dispatch(backendActions.getEvent(props.id))
    done()
  }

  useEffect(() => {
    logger.debug(`props.id=${props.id}`)
    dispatch(backendActions.getEvent(props.id))
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  useEffect(() => {
    if (!error) {
      return
    }

    logger.error('error on component', error)
    f7.dialog.alert(
      error?.message || t('unknownError', { postProcess: 'capitalize' }),
      () => {
        dispatch(backendActions.clearError())
      },
    )
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [error])

  const getDecisionName = (decision: string): string => {
    if (decision === 'Decision') {
      return t('decision', { postProcess: 'capitalize' })
    } else if (decision === 'TKO') {
      return t('tko', { postProcess: 'capitalize' })
    } else if (decision === 'Submission') {
      return t('submission', { postProcess: 'capitalize' })
    } else if (decision === 'KO') {
      return t('ko', { postProcess: 'capitalize' })
    } else if (decision === 'Technical Submission') {
      return t('technicalSubmission', { postProcess: 'capitalize' })
    } else if (decision === 'No Contest') {
      return t('noContest', { postProcess: 'capitalize' })
    } else if (decision === 'Draw') {
      return t('draw', { postProcess: 'capitalize' })
    } else if (decision === 'Disqualification') {
      return t('disqualification', { postProcess: 'capitalize' })
    } else if (decision === 'Technical Decision') {
      return t('technicalDecision', { postProcess: 'capitalize' })
    }
    return decision
  }
  const getDecisionMethodName = (method: string): string => {
    if (method === 'Unanimous') {
      return t('unanimous', { postProcess: 'capitalize' })
    } else if (method === 'Punches') {
      return t('punches', { postProcess: 'capitalize' })
    } else if (method === 'Split') {
      return t('split', { postProcess: 'capitalize' })
    } else if (method === 'Rear-Naked Choke') {
      return t('rearNakedChoke', { postProcess: 'capitalize' })
    } else if (method === 'Punch') {
      return t('punch', { postProcess: 'capitalize' })
    } else if (method === 'Guillotine Choke') {
      return t('guillotineChoke', { postProcess: 'capitalize' })
    } else if (method === 'Armbar') {
      return t('armbar', { postProcess: 'capitalize' })
    } else if (method === 'Arm-Triangle Choke') {
      return t('armTriangleChoke', { postProcess: 'capitalize' })
    } else if (method === 'Majority') {
      return t('majority', { postProcess: 'capitalize' })
    } else if (method === 'Triangle Choke') {
      return t('triangleChoke', { postProcess: 'capitalize' })
    } else if (method === 'Doctor Stoppage') {
      return t('doctorStoppage', { postProcess: 'capitalize' })
    } else if (method === 'Elbows') {
      return t('elbows', { postProcess: 'capitalize' })
    } else if (method === 'Elbows and Punches') {
      return t('elbowsAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Punches and Elbows') {
      return t('punchesAndElbows', { postProcess: 'capitalize' })
    } else if (method === 'Head Kick and Punches') {
      return t('headKickAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Head Kick') {
      return t('headKick', { postProcess: 'capitalize' })
    } else if (method === 'Knee and Punches') {
      return t('kneeAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Brabo Choke') {
      return t('braboChoke', { postProcess: 'capitalize' })
    } else if (method === 'Kimura') {
      return t('kimura', { postProcess: 'capitalize' })
    } else if (method === 'Knee') {
      return t('knee', { postProcess: 'capitalize' })
    } else if (method === 'Submission to Punches') {
      return t('submissionToPunches', { postProcess: 'capitalize' })
    } else if (method === 'Anaconda Choke') {
      return t('anacondaChoke', { postProcess: 'capitalize' })
    } else if (method === 'Knees and Punches') {
      return t('kneesAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Corner Stoppage') {
      return t('cornerStoppage', { postProcess: 'capitalize' })
    } else if (method === 'Kneebar') {
      return t('kneebar', { postProcess: 'capitalize' })
    } else if (method === 'Heel Hook') {
      return t('heelHook', { postProcess: 'capitalize' })
    } else if (method === 'Overturned') {
      return t('overturned', { postProcess: 'capitalize' })
    } else if (method === 'Triangle Armbar') {
      return t('triangleArmbar', { postProcess: 'capitalize' })
    } else if (method === 'Flying Knee') {
      return t('flyingKnee', { postProcess: 'capitalize' })
    } else if (method === 'Face Crank') {
      return t('faceCrank', { postProcess: 'capitalize' })
    } else if (method === 'Elbow') {
      return t('elbow', { postProcess: 'capitalize' })
    } else if (method === 'Knee Injury') {
      return t('kneeInjury', { postProcess: 'capitalize' })
    } else if (method === 'Body Kick and Punches') {
      return t('bodyKickAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Neck Crank') {
      return t('neckCrank', { postProcess: 'capitalize' })
    } else if (method === 'Flying Knee and Punches') {
      return t('flyingKneeAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Punch to the Body') {
      return t('punchToTheBody', { postProcess: 'capitalize' })
    } else if (method === 'Slam') {
      return t('slam', { postProcess: 'capitalize' })
    } else if (method === 'Knees') {
      return t('knees', { postProcess: 'capitalize' })
    } else if (method === 'Knee to the Body and Punches') {
      return t('kneeToTheBodyAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Illegal Knee') {
      return t('illegalKnee', { postProcess: 'capitalize' })
    } else if (method === 'Elbow and Punches') {
      return t('elbowAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Accidental Eye Poke') {
      return t('accidentalEyePoke', { postProcess: 'capitalize' })
    } else if (method === 'Retirement') {
      return t('retirement', { postProcess: 'capitalize' })
    } else if (method === 'Shoulder Choke') {
      return t('shoulderChoke', { postProcess: 'capitalize' })
    } else if (method === 'Kick to the Body and Punches') {
      return t('kickToTheBodyAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Straight Armbar') {
      return t('straightArmbar', { postProcess: 'capitalize' })
    } else if (method === 'Spinning Wheel Kick and Punches') {
      return t('spinningWheelKickAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Punches and Knees') {
      return t('punchesAndKnees', { postProcess: 'capitalize' })
    } else if (method === 'Leg Injury') {
      return t('legInjury', { postProcess: 'capitalize' })
    } else if (method === 'Keylock') {
      return t('keylock', { postProcess: 'capitalize' })
    } else if (method === 'Body Kick') {
      return t('bodyKick', { postProcess: 'capitalize' })
    } else if (method === 'Punches and Knee') {
      return t('punchesAndKnee', { postProcess: 'capitalize' })
    } else if (method === 'Overturned by NSAC') {
      return t('overturnedByNsac', { postProcess: 'capitalize' })
    } else if (method === 'Leg Kicks') {
      return t('legKicks', { postProcess: 'capitalize' })
    } else if (method === 'Achilles Lock') {
      return t('achillesLock', { postProcess: 'capitalize' })
    } else if (method === 'Submission to Elbows') {
      return t('submissionToElbows', { postProcess: 'capitalize' })
    } else if (method === 'Spinning Wheel Kick') {
      return t('spinningWheelKick', { postProcess: 'capitalize' })
    } else if (method === 'Spinning Backfist') {
      return t('spinningBackfist', { postProcess: 'capitalize' })
    } else if (method === 'Spinning Back Kick and Punches') {
      return t('spinningBackKickAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Scarf Hold') {
      return t('scarfHold', { postProcess: 'capitalize' })
    } else if (method === 'Leg Kick') {
      return t('legKick', { postProcess: 'capitalize' })
    } else if (method === 'Knee to the Body') {
      return t('kneeToTheBody', { postProcess: 'capitalize' })
    } else if (method === 'Cut') {
      return t('cut', { postProcess: 'capitalize' })
    } else if (method === 'Arm Injury') {
      return t('armInjury', { postProcess: 'capitalize' })
    } else if (method === 'Spinning Back Elbow') {
      return t('spinningBackElbow', { postProcess: 'capitalize' })
    } else if (method === 'Accidental Clash of Heads') {
      return t('accidentalClashOfHeads', { postProcess: 'capitalize' })
    } else if (method === 'Shoulder Injury') {
      return t('shoulderInjury', { postProcess: 'capitalize' })
    } else if (method === 'North-South Choke') {
      return t('northSouthChoke', { postProcess: 'capitalize' })
    } else if (method === 'Knee and Elbows') {
      return t('kneeAndElbows', { postProcess: 'capitalize' })
    } else if (method === 'Front Kick and Punches') {
      return t('frontKickAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Forearm Choke') {
      return t('forearmChoke', { postProcess: 'capitalize' })
    } else if (method === 'Bulldog Choke') {
      return t('bulldogChoke', { postProcess: 'capitalize' })
    } else if (method === 'Premature Stoppage') {
      return t('prematureStoppage', { postProcess: 'capitalize' })
    } else if (method === 'Overturned by Commission') {
      return t('overturnedByCommission', { postProcess: 'capitalize' })
    } else if (method === 'Ninja Choke') {
      return t('ninjaChoke', { postProcess: 'capitalize' })
    } else if (method === 'Knees to the Body') {
      return t('kneesToTheBody', { postProcess: 'capitalize' })
    } else if (method === 'Head Kick and Punch') {
      return t('headKickAndPunch', { postProcess: 'capitalize' })
    } else if (method === 'Front Kick') {
      return t('frontKick', { postProcess: 'capitalize' })
    } else if (method === 'Ezekiel Choke') {
      return t('ezekielChoke', { postProcess: 'capitalize' })
    } else if (method === 'Twister') {
      return t('twister', { postProcess: 'capitalize' })
    } else if (method === 'Superman Punch') {
      return t('supermanPunch', { postProcess: 'capitalize' })
    } else if (method === 'Submission to Punch') {
      return t('submissionToPunch', { postProcess: 'capitalize' })
    } else if (method === 'Rib Injury') {
      return t('ribInjury', { postProcess: 'capitalize' })
    } else if (method === 'Reverse Triangle Armbar') {
      return t('reverseTriangleArmbar', { postProcess: 'capitalize' })
    } else if (method === 'Punches to the Body') {
      return t('punchesToTheBody', { postProcess: 'capitalize' })
    } else if (method === 'Punches to Back of Head') {
      return t('punchesToBackOfHead', { postProcess: 'capitalize' })
    } else if (method === 'Overturned by Promoter') {
      return t('overturnedByPromoter', { postProcess: 'capitalize' })
    } else if (method === 'Overturned by CSAC') {
      return t('overturnedByCsac', { postProcess: 'capitalize' })
    } else if (method === 'Kick to the Body') {
      return t('kickToTheBody', { postProcess: 'capitalize' })
    } else if (method === 'Inverted Triangle Kimura') {
      return t('invertedTriangleKimura', { postProcess: 'capitalize' })
    } else if (method === 'Illegal Upkick') {
      return t('illegalUpkick', { postProcess: 'capitalize' })
    } else if (method === 'Eye Injury') {
      return t('eyeInjury', { postProcess: 'capitalize' })
    } else if (method === 'Time Limit') {
      return t('timeLimit', { postProcess: 'capitalize' })
    } else if (method === 'Suplex and Punches') {
      return t('suplexAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Submission to Elbow') {
      return t('submissionToElbow', { postProcess: 'capitalize' })
    } else if (method === 'Spinning Back Kick') {
      return t('spinningBackKick', { postProcess: 'capitalize' })
    } else if (method === 'Spinning Back Fist') {
      return t('spinningBackFist', { postProcess: 'capitalize' })
    } else if (method === 'Slam and Punches') {
      return t('slamAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Scarf Hold Armlock') {
      return t('scarfHoldArmlock', { postProcess: 'capitalize' })
    } else if (method === 'Punch and Knee') {
      return t('punchAndKnee', { postProcess: 'capitalize' })
    } else if (method === 'Punch and Head Kick') {
      return t('punchAndHeadKick', { postProcess: 'capitalize' })
    } else if (method === 'Position') {
      return t('position', { postProcess: 'capitalize' })
    } else if (method === 'Peruvian Necktie') {
      return t('peruvianNecktie', { postProcess: 'capitalize' })
    } else if (method === 'Overturned by TDLR') {
      return t('overturnedByTdrl', { postProcess: 'capitalize' })
    } else if (method === 'Overturned by CABMMA') {
      return t('overturnedByCabmma', { postProcess: 'capitalize' })
    } else if (method === 'Omoplata') {
      return t('omoplata', { postProcess: 'capitalize' })
    } else if (method === 'Neck Injury') {
      return t('neckInjury', { postProcess: 'capitalize' })
    } else if (method === 'Leg Kicks and Punches') {
      return t('legKicksAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Leg Kick and Punches') {
      return t('legKickAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Lapel Choke') {
      return t('lapelChoke', { postProcess: 'capitalize' })
    } else if (method === 'Knee and Punch') {
      return t('kneeAndPunch', { postProcess: 'capitalize' })
    } else if (method === 'Jaw Injury') {
      return t('jawInjury', { postProcess: 'capitalize' })
    } else if (method === 'Inverted Triangle Choke') {
      return t('invertedTriangleChoke', { postProcess: 'capitalize' })
    } else if (method === 'Illegal Elbows') {
      return t('illegalElbows', { postProcess: 'capitalize' })
    } else if (method === 'Front Kick to the Body and Punches') {
      return t('frontKickToTheBodyAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Flying Triangle Choke') {
      return t('flyingTriangleChoke', { postProcess: 'capitalize' })
    } else if (method === 'Elbows and Knees') {
      return t('elbowsAndKnees', { postProcess: 'capitalize' })
    } else if (method === 'Elbow and Punch') {
      return t('elbowAndPunch', { postProcess: 'capitalize' })
    } else if (method === 'Choke') {
      return t('choke', { postProcess: 'capitalize' })
    } else if (method === 'Calf Slicer') {
      return t('calfSlicer', { postProcess: 'capitalize' })
    } else if (method === 'Body Triangle') {
      return t('bodyTriangle', { postProcess: 'capitalize' })
    } else if (method === 'Ankle Injury') {
      return t('ankleInjury', { postProcess: 'capitalize' })
    } else if (method === 'Accidental Groin Kick') {
      return t('accidentalGroinKick', { postProcess: 'capitalize' })
    } else if (method === 'Upkick to the Body') {
      return t('upkickToTheBody', { postProcess: 'capitalize' })
    } else if (method === 'Upkick and Punches') {
      return t('upkickAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Upkick') {
      return t('upkick', { postProcess: 'capitalize' })
    } else if (method === 'Triangle Kimura') {
      return t('triangleKimura', { postProcess: 'capitalize' })
    } else if (method === 'Toe Hold') {
      return t('toeHold', { postProcess: 'capitalize' })
    } else if (method === 'Thumb Injury') {
      return t('thumbInjury', { postProcess: 'capitalize' })
    } else if (method === 'Submission to Slam') {
      return t('submissionToSlam', { postProcess: 'capitalize' })
    } else if (method === 'Submission to Knee to the Body') {
      return t('submissionToKneeToTheBody', { postProcess: 'capitalize' })
    } else if (method === 'Submission to Heel Strikes') {
      return t('submissionToHeelStrikes', { postProcess: 'capitalize' })
    } else if (method === 'Submission to Headbutts') {
      return t('submissionToHeadbutts', { postProcess: 'capitalize' })
    } else if (method === 'Submission to Elbows to the Body') {
      return t('submissionToElbowsToTheBody', { postProcess: 'capitalize' })
    } else if (method === 'Straight Armlock') {
      return t('straightArmlock', { postProcess: 'capitalize' })
    } else if (method === 'Spinning Hook Kick and Punches') {
      return t('spinningHookKickAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Spinning Hook Kick') {
      return t('spinningHookKick', { postProcess: 'capitalize' })
    } else if (method === 'Spinning Heel Kick and Punches') {
      return t('spinningHeelKickAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Spinning Backfists') {
      return t('spinningBackfists', { postProcess: 'capitalize' })
    } else if (method === 'Spinning Backfist and Punches') {
      return t('spinningBackfistAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Spinning Backfist and Elbows') {
      return t('spinningBackfistAndElbows', { postProcess: 'capitalize' })
    } else if (method === 'Spinning Back Fist and Punches') {
      return t('spinningBackFistAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Spinning Back Elbow and Punches') {
      return t('spinningBackElbowAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Soccer Kick to the Body') {
      return t('soccerKickToTheBody', { postProcess: 'capitalize' })
    } else if (method === 'Soccer Kick') {
      return t('soccerKick', { postProcess: 'capitalize' })
    } else if (method === 'Smother Choke') {
      return t('smotherChoke', { postProcess: 'capitalize' })
    } else if (method === 'Slam and Punch') {
      return t('slamAndPunch', { postProcess: 'capitalize' })
    } else if (method === 'Slam and Elbows') {
      return t('slamAndElbows', { postProcess: 'capitalize' })
    } else if (method === 'Side Kick and Punches') {
      return t('sideKickAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Sakara Kicked in Groin') {
      return t('sakaraKickedInGroin', { postProcess: 'capitalize' })
    } else if (method === 'Reverse Bulldog Choke') {
      return t('reverseBulldogChoke', { postProcess: 'capitalize' })
    } else if (method === 'Reverse Armbar') {
      return t('reverseArmbar', { postProcess: 'capitalize' })
    } else if (method === 'Repeated Fouls') {
      return t('repeatedFouls', { postProcess: 'capitalize' })
    } else if (method === 'Punches and Head Kick') {
      return t('punchesAndHeadKick', { postProcess: 'capitalize' })
    } else if (method === 'Punches and Elbows to the Body') {
      return t('punchesAndElbowsToTheBody', { postProcess: 'capitalize' })
    } else if (method === 'Punches and Elbow') {
      return t('punchesAndElbow', { postProcess: 'capitalize' })
    } else if (method === 'Punches After the Bell') {
      return t('punchesAfterTheBell', { postProcess: 'capitalize' })
    } else if (method === 'Punch and Elbows') {
      return t('punchAndElbows', { postProcess: 'capitalize' })
    } else if (method === 'Pillory Choke') {
      return t('pilloryChoke', { postProcess: 'capitalize' })
    } else if (method === 'Overturned by VPBCSB') {
      return t('overturnedByVpbcsb', { postProcess: 'capitalize' })
    } else if (method === 'Overturned by State Commission') {
      return t('overturnedByStateCommission', { postProcess: 'capitalize' })
    } else if (method === 'Overturned by STJDMMA') {
      return t('overturnedByStjdMma', { postProcess: 'capitalize' })
    } else if (method === 'Overturned by MSAC') {
      return t('overturnedByMsac', { postProcess: 'capitalize' })
    } else if (method === 'Overturned by CCSC') {
      return t('overturnedByCcsc', { postProcess: 'capitalize' })
    } else if (method === 'Leg Kick and Elbows') {
      return t('legKickAndElbows', { postProcess: 'capitalize' })
    } else if (method === 'Knees to the Body and Punches') {
      return t('kneesToTheBodyAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Knees and Elbow') {
      return t('kneesAndElbow', { postProcess: 'capitalize' })
    } else if (method === 'Knee to the Body and Head Kicks') {
      return t('kneeToTheBodyAndHeadKicks', { postProcess: 'capitalize' })
    } else if (method === 'Knee to the Body and Elbows') {
      return t('kneeToTheBodyAndElbows', { postProcess: 'capitalize' })
    } else if (method === 'Knee to the Body and Elbow') {
      return t('kneeToTheBodyAndElbow', { postProcess: 'capitalize' })
    } else if (method === 'Knee and Body Kick') {
      return t('kneeAndBodyKick', { postProcess: 'capitalize' })
    } else if (method === 'Kicking a Downed Opponent') {
      return t('kickingADownedOpponent', { postProcess: 'capitalize' })
    } else if (method === 'Kick to the Body and Elbows') {
      return t('kickToTheBodyAndElbows', { postProcess: 'capitalize' })
    } else if (method === 'Japanese Necktie') {
      return t('japaneseNecktie', { postProcess: 'capitalize' })
    } else if (method === 'Inverted Heel Hook') {
      return t('invertedHeelHook', { postProcess: 'capitalize' })
    } else if (method === 'Inside Shoulder Lock') {
      return t('insideShoulderLock', { postProcess: 'capitalize' })
    } else if (method === 'Injury') {
      return t('injury', { postProcess: 'capitalize' })
    } else if (method === 'Illegal Kicks') {
      return t('illegalKicks', { postProcess: 'capitalize' })
    } else if (method === 'Illegal Kick') {
      return t('illegalKick', { postProcess: 'capitalize' })
    } else if (method === 'Illegal Elbow') {
      return t('illegalElbow', { postProcess: 'capitalize' })
    } else if (method === 'Hook Kick and Punches') {
      return t('hookKickAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Hoffman Failed Drug Test') {
      return t('hoffmanFailedDrugTest', { postProcess: 'capitalize' })
    } else if (method === 'Headbutts') {
      return t('headbutts', { postProcess: 'capitalize' })
    } else if (method === 'Head Kicks and Punches') {
      return t('headKicksAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Head Kick and Knee') {
      return t('headKickAndKnee', { postProcess: 'capitalize' })
    } else if (method === 'Hand Injury') {
      return t('handInjury', { postProcess: 'capitalize' })
    } else if (method === 'Front Kick to the Body and Punch') {
      return t('frontKickToTheBodyAndPunch', { postProcess: 'capitalize' })
    } else if (method === 'Front Kick to the Body') {
      return t('frontKickToTheBody', { postProcess: 'capitalize' })
    } else if (method === 'Front Kick and Punch') {
      return t('frontKickAndPunch', { postProcess: 'capitalize' })
    } else if (method === 'Front Kick and Knees') {
      return t('frontKickAndKnees', { postProcess: 'capitalize' })
    } else if (method === 'Front Choke') {
      return t('frontChoke', { postProcess: 'capitalize' })
    } else if (method === 'Flying Knee to the Body') {
      return t('flyingKneeToTheBody', { postProcess: 'capitalize' })
    } else if (method === 'Flying Knee and Punch') {
      return t('flyingKneeAndPunch', { postProcess: 'capitalize' })
    } else if (method === 'Flying Head Kick and Punches') {
      return t('flyingHeadKickAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Finger Injury') {
      return t('fingerInjury', { postProcess: 'capitalize' })
    } else if (method === 'Fatigue') {
      return t('fatigue', { postProcess: 'capitalize' })
    } else if (method === 'Failed Drug Test') {
      return t('failedDrugTest', { postProcess: 'capitalize' })
    } else if (method === 'Eye Poke') {
      return t('eyePoke', { postProcess: 'capitalize' })
    } else if (method === 'Eye Gouging') {
      return t('eyeGouging', { postProcess: 'capitalize' })
    } else if (method === 'Exhaustion') {
      return t('exhaustion', { postProcess: 'capitalize' })
    } else if (method === 'Esophagus Injury') {
      return t('esophagusInjury', { postProcess: 'capitalize' })
    } else if (method === 'Elbows to Back of Head') {
      return t('elbowsToBackOfHead', { postProcess: 'capitalize' })
    } else if (method === 'Double TKO') {
      return t('doubleTko', { postProcess: 'capitalize' })
    } else if (method === 'Crucifix Choke') {
      return t('crucifixChoke', { postProcess: 'capitalize' })
    } else if (method === 'Chin to the Eye') {
      return t('chinToTheEye', { postProcess: 'capitalize' })
    } else if (method === 'Caceres Failed Drug Test') {
      return t('caceresFailedDrugTest', { postProcess: 'capitalize' })
    } else if (method === 'Body Lock') {
      return t('bodyLock', { postProcess: 'capitalize' })
    } else if (method === 'Body Kicks and Punches') {
      return t('bodyKicksAndPunches', { postProcess: 'capitalize' })
    } else if (method === 'Body Kick and Punch') {
      return t('bodyKickAndPunch', { postProcess: 'capitalize' })
    } else if (method === 'Biting') {
      return t('biting', { postProcess: 'capitalize' })
    } else if (method === 'Armlock') {
      return t('armlock', { postProcess: 'capitalize' })
    } else if (method === 'Ankle Lock') {
      return t('ankleLock', { postProcess: 'capitalize' })
    }
    return method
  }

  const getCategoryName = (categoryName: string): string => {
    if (categoryName === 'Strawweight') {
      return t('Strawweight', { postProcess: 'capitalize' })
    } else if (categoryName === 'Flyweight') {
      return t('Flyweight', { postProcess: 'capitalize' })
    } else if (categoryName === 'Bantamweight') {
      return t('Bantamweight', { postProcess: 'capitalize' })
    } else if (categoryName === 'Featherweight') {
      return t('Featherweight', { postProcess: 'capitalize' })
    } else if (categoryName === 'Lightweight') {
      return t('Lightweight', { postProcess: 'capitalize' })
    } else if (categoryName === 'Welterweight') {
      return t('Welterweight', { postProcess: 'capitalize' })
    } else if (categoryName === 'Middleweight') {
      return t('Middleweight', { postProcess: 'capitalize' })
    } else if (categoryName === 'Light Heavyweight') {
      return t('Light Heavyweight', { postProcess: 'capitalize' })
    } else if (categoryName === 'Heavyweight') {
      return t('Heavyweight', { postProcess: 'capitalize' })
    }
    return categoryName
  }

  return (
    <Page ptr ptrMousewheel={true} onPtrRefresh={onPullRefreshed}>
      <Navbar
        title={event?.name ?? t('event', { postProcess: 'capitalize' })}
        large
        backLink
      />
      <BlockTitle>{t('event', { postProcess: 'capitalize' })}</BlockTitle>
      <List dividersIos mediaList strongIos inset>
        {state === 'getting_event' && (
          <ListItem
            className="skeleton-text skeleton-effect-wave"
            title={EmptyEvent.name}
            subtitle={EmptyEvent.fight}
            after={'uppcoming'}
          >
            <br />
            <div>
              {EmptyEvent.date.toISOString().split('T')[0]}
              {' in 34 days'}
            </div>
            <div>
              {EmptyEvent.location.city.country.name} -{' '}
              {EmptyEvent.location.city.name}
            </div>
            <div>
              {EmptyEvent.location.name !== '' && EmptyEvent.location.name}
            </div>
          </ListItem>
        )}
        {state !== 'getting_event' && event && (
          <ListItem
            key={event.id}
            title={event.name}
            subtitle={event.fight}
            after={
              event.status === 'uppcoming'
                ? t('upcoming', { postProcess: 'capitalize' })
                : ''
            }
          >
            <br />
            <div>
              <FontAwesomeIcon className="w-4" icon={faCalendar} />{' '}
              <span className="opacity-60">
                {event.date.toISOString().split('T')[0]}
              </span>{' '}
              {event.status === 'uppcoming' && (
                <span className="opacity-60">
                  {t('inXXDays', {
                    days: DateUtils.daysBetween(event.date, new Date()),
                  })}
                </span>
              )}
            </div>
            <div>
              <FontAwesomeIcon className="w-4" icon={faMap} />{' '}
              <span className="opacity-60">
                {event.location.city.country.name} - {event.location.city.name}
              </span>
            </div>
            <div>
              {event.location.name !== '' && (
                <>
                  <FontAwesomeIcon className="w-4" icon={faLocation} />{' '}
                  <span className="opacity-60">{event.location.name}</span>
                </>
              )}
            </div>
          </ListItem>
        )}
      </List>

      <BlockTitle>{t('fights', { postProcess: 'capitalize' })}</BlockTitle>
      <List dividersIos mediaList strongIos inset>
        {state === 'getting_event' &&
          Faker.arrayOfNumbers(5).map((i: number) => (
            <ListItem
              className="skeleton-text skeleton-effect-wave"
              key={i}
              chevronCenter
              title={`${EmptyFight.fighterOne.name} vs. ${EmptyFight.fighterTwo.name}`}
              subtitle="EmptyFight.titleFight"
            >
              <br />
              {EmptyFight.category && (
                <div>
                  {EmptyFight.category.name} ({EmptyFight.category.weight} lbs)
                </div>
              )}
              {EmptyFight.type === 'done' && (
                <>
                  <div>
                    {EmptyFight.decision} ({EmptyFight.method})
                  </div>
                  {EmptyFight.decision !== 'Decision' && (
                    <div>
                      {t('round', { postProcess: 'capitalize' })}{' '}
                      {EmptyFight.round} {t('at')}{' '}
                      {DateUtils.secondsToMMSS(EmptyFight.time!)}
                    </div>
                  )}
                </>
              )}
            </ListItem>
          ))}

        {state !== 'getting_event' && fights.length === 0 && (
          <ListItem
            subtitle={t('fightsNotFound', { postProcess: 'capitalize' })}
          />
        )}
        {state !== 'getting_event' &&
          fights.map((fight: Fight) => (
            <ListItem
              key={fight.id}
              link={`/fights/${fight.id}`}
              chevronCenter
              title={`${fight.fighterOne.name} vs. ${fight.fighterTwo.name}`}
              subtitle={
                fight.titleFight
                  ? t('titleFight', { postProcess: 'capitalize' })
                  : ''
              }
            >
              <br />
              {fight.category && (
                <div>
                  <FontAwesomeIcon className="w-4" icon={faWeight} />{' '}
                  {getCategoryName(fight.category.name)} (
                  {fight.category.weight} lbs)
                </div>
              )}
              {fight.type === 'done' && (
                <>
                  <div>
                    <FontAwesomeIcon
                      className="w-4"
                      icon={faPersonChalkboard}
                    />{' '}
                    {fight.decision && getDecisionName(fight.decision)} (
                    {fight.method && getDecisionMethodName(fight.method)})
                  </div>
                  {fight.decision !== 'Decision' && (
                    <div>
                      <FontAwesomeIcon className="w-4" icon={faClock} />{' '}
                      {t('round', { postProcess: 'capitalize' })} {fight.round}{' '}
                      {t('at')} {DateUtils.secondsToMMSS(fight.time!)}
                    </div>
                  )}
                </>
              )}
            </ListItem>
          ))}
      </List>
      <Toolbar bottom>
        <div />
        {state === 'getting_event' && (
          <div className="skeleton-text skeleton-effect-wave">
            {t('fightsCounter', { count: 0 })}
          </div>
        )}
        {state !== 'getting_event' && (
          <div>{t('fightsCounter', { count: fights.length })}</div>
        )}
        <div />
      </Toolbar>
    </Page>
  )
}
