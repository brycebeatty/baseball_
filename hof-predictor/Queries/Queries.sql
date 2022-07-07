select
	p.nameFirst,
	p.nameLast,
	a.awardID,
	af.AS_APP,
	count(*)
from baseball.people p
inner join baseball.AwardsPlayers a
on p.playerID = a.playerID
inner join (
select 
	playerID,
	count(distinct YearID) as AS_APP
from baseball.AllstarFull
group by playerID
)af
on p.playerID = af.playerID
where p.nameFirst = 'Salvador' and p.nameLast = 'Perez'
group by p.nameFirst, p.nameLast, a.awardID, af.AS_APP;