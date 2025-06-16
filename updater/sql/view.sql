drop view if exists fights_with_figthers;

create view fights_with_figthers as
select
  fighterOne.id as fighterOneId,
  fighterOne.name as fighterOneName,
  fighterOne.nickname as fighterOneNickname,
  fighterOne."cityId" as fighterOneCityId,
  fighterOne.birthday as fighterOneBirthday,
  fighterOne.died as fighterOneDied,
  fighterOne.height as fighterOneHeight,
  fighterOne.weight as fighterOneWeight,
  fighterOne.link as fighterOneLink,
  
  fighterTwo.id as fighterTwoId,
  fighterTwo.name as fighterTwoName,
  fighterTwo.nickname as fighterTwoNickname,
  fighterTwo."cityId" as fighterTwoCityId,
  fighterTwo.birthday as fighterTwoBirthday,
  fighterTwo.died as fighterTwoDied,
  fighterTwo.height as fighterTwoHeight,
  fighterTwo.weight as fighterTwoWeight,
  fighterTwo.link as fighterTwoLink,

  fights.*
from fights
left join fighters fighterOne
  on fights."fighterOneId" = fighterOne.id
left join fighters fighterTwo
  on fights."fighterTwoId" = fighterTwo.id;

select * from fights_with_figthers;
