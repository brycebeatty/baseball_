WITH PEOPLE AS (
select
	playerID,
	nameFirst,
	nameLast,
	bats,
	throws,
	debut
from baseball.people
where debut > '12-31-1959'
and playerid not in (
select distinct playerid
from baseball.MitchellReport
)
),

BATTING AS (
select
	p.playerID,
	p.bats,
	SUM(b.AB) AB,
	SUM(b.BB) WALKS,
	SUM(b.H) HITS,
	(isnull(SUM(b.H),0)- (isnull(SUM(b._2B),0)+isnull(SUM(b._3B),0)+isnull(SUM(b.HR),0))) SINGLES,
	SUM(b._2B) DOUBLES,
	SUM(b._3B) TRIPLES,
	SUM(b.HR) HR,
	SUM(b.HBP) HBP,
	SUM(b.SF) SACF,
	SUM(b.R) RUNS,
	SUM(b.RBI) RBI,
	SUM(b.SB) SB
from PEOPLE p
inner join baseball.batting b
on p.playerID = b.playerID
GROUP BY 
	P.PLAYERID,
	P.BATS
),

BATTING_POST AS (
select
	p.playerID,
	SUM(b.AB) POST_AB,
	SUM(b.H) POST_H,
	SUM(b.G) POST_GAMES
from people p
inner join baseball.BattingPost b
on p.playerID = b.playerID
GROUP BY 
	P.PLAYERID
),

FIELDING AS (
select
	p.playerID,
	p.throws,
	SUM(f.a) ASSISTS,
	SUM(f.po) PO,
	SUM(f.e) ERRORS
from people p
inner join baseball.Fielding f
on p.playerID = f.playerID
GROUP BY 
	P.PLAYERID,
	p.throws
),

ALL_STAR AS (
select
	p.playerID,
	SUM(convert(smallint, a.gp)) AS_GAMES
from people p
inner join Baseball.allstarfull a
on p.playerID = a.playerID
GROUP BY 
	P.PLAYERID
),

AWARDS AS (
select
	p.playerID,
	sum(case when a.awardID = 'Most Valuable Player' then 1 else 0 end) MVP,
	sum(case when a.awardID = 'Gold Glove' then 1 else 0 end) GG
from people p
inner join baseball.AwardsPlayers a
on p.playerID = a.playerID
group by p.playerID
),

WS_WINS AS (
select
	p.playerID,
	count(s.yearID) ws_WINS
from people p
inner join baseball.Appearances a
on a.playerID = p.playerID
inner join baseball.SeriesPost s
on a.yearID = s.yearID
and a.teamID = s.teamIDwinner
where s.round = 'WS'
GROUP BY 
	P.PLAYERID
),

WS_LOSSES AS (
select
	p.playerID,
	count(s.yearID) ws_LOSSES
from people p
inner join baseball.appearances a
on a.playerID = p.playerID
inner join baseball.SeriesPost s
on a.yearID = s.yearID
and a.teamID = s.teamIDloser
where s.round = 'WS'
GROUP BY 
	P.PLAYERID
),

HOF AS (
SELECT
	p.playerID,
	min(h.yearID) as firstyear,
	max(convert(smallint, h.inducted)) as inducted
from people p
inner join baseball.HallOfFame h
on p.playerID = h.playerID
where h.category = 'Player'
group by p.playerID
),

APPEARANCES AS (
select
	p.playerID,
	SUM(a.g_all) GP,
	CASE 
		WHEN SUM(A.G_c) > SUM(A.G_1B) AND SUM(A.G_c) > SUM(A.G_2B) AND SUM(A.G_c) > SUM(A.G_3B) AND SUM(A.G_c) > SUM(A.G_SS) AND SUM(A.G_c) > SUM(A.G_LF) AND SUM(A.G_c) > SUM(A.G_CF) AND SUM(A.G_c) > SUM(A.G_RF) AND SUM(A.G_c) > SUM(A.G_DH) AND SUM(A.G_C) > SUM(A.G_P) THEN 'CATCHER'
		WHEN SUM(A.G_1B) > SUM(A.G_C) AND SUM(A.G_1B) > SUM(A.G_2B) AND SUM(A.G_1B) > SUM(A.G_3B) AND SUM(A.G_1B) > SUM(A.G_SS) AND SUM(A.G_1B) > SUM(A.G_LF) AND SUM(A.G_1B) > SUM(A.G_CF) AND SUM(A.G_1B) > SUM(A.G_RF) AND SUM(A.G_1B) > SUM(A.G_DH) AND SUM(A.G_1B) > SUM(A.G_P) THEN '1B'
		WHEN SUM(A.G_2B) > SUM(A.G_C) AND SUM(A.G_2B) > SUM(A.G_1B) AND SUM(A.G_2B) > SUM(A.G_3B) AND SUM(A.G_2B) > SUM(A.G_SS) AND SUM(A.G_2B) > SUM(A.G_LF) AND SUM(A.G_2B) > SUM(A.G_CF) AND SUM(A.G_2B) > SUM(A.G_RF) AND SUM(A.G_2B) > SUM(A.G_DH) AND SUM(A.G_2B) > SUM(A.G_P) THEN '2B'
		WHEN SUM(A.G_3B) > SUM(A.G_C) AND SUM(A.G_3B) > SUM(A.G_1B) AND SUM(A.G_3B) > SUM(A.G_2B) AND SUM(A.G_3B) > SUM(A.G_SS) AND SUM(A.G_3B) > SUM(A.G_LF) AND SUM(A.G_3B) > SUM(A.G_CF) AND SUM(A.G_3B) > SUM(A.G_RF) AND SUM(A.G_3B) > SUM(A.G_DH) AND SUM(A.G_3B) > SUM(A.G_P) THEN '3B'
		WHEN SUM(A.G_SS) > SUM(A.G_C) AND SUM(A.G_SS) > SUM(A.G_1B) AND SUM(A.G_SS) > SUM(A.G_2B) AND SUM(A.G_SS) > SUM(A.G_3B) AND SUM(A.G_SS) > SUM(A.G_LF) AND SUM(A.G_SS) > SUM(A.G_CF) AND SUM(A.G_SS) > SUM(A.G_RF) AND SUM(A.G_SS) > SUM(A.G_DH) AND SUM(A.G_SS) > SUM(A.G_P) THEN 'SS'
		WHEN SUM(A.G_LF) > SUM(A.G_C) AND SUM(A.G_LF) > SUM(A.G_1B) AND SUM(A.G_LF) > SUM(A.G_2B) AND SUM(A.G_LF) > SUM(A.G_3B) AND SUM(A.G_LF) > SUM(A.G_SS) AND SUM(A.G_LF) > SUM(A.G_CF) AND SUM(A.G_LF) > SUM(A.G_RF) AND SUM(A.G_LF) > SUM(A.G_DH) AND SUM(A.G_LF) > SUM(A.G_P) THEN 'LF'
		WHEN SUM(A.G_CF) > SUM(A.G_C) AND SUM(A.G_CF) > SUM(A.G_1B) AND SUM(A.G_CF) > SUM(A.G_2B) AND SUM(A.G_CF) > SUM(A.G_3B) AND SUM(A.G_CF) > SUM(A.G_SS) AND SUM(A.G_CF) > SUM(A.G_LF) AND SUM(A.G_CF) > SUM(A.G_RF) AND SUM(A.G_CF) > SUM(A.G_DH) AND SUM(A.G_CF) > SUM(A.G_P) THEN 'CF'
		WHEN SUM(A.G_RF) > SUM(A.G_C) AND SUM(A.G_RF) > SUM(A.G_1B) AND SUM(A.G_RF) > SUM(A.G_2B) AND SUM(A.G_RF) > SUM(A.G_3B) AND SUM(A.G_RF) > SUM(A.G_SS) AND SUM(A.G_RF) > SUM(A.G_LF) AND SUM(A.G_RF) > SUM(A.G_CF) AND SUM(A.G_RF) > SUM(A.G_DH) AND SUM(A.G_RF) > SUM(A.G_P) THEN 'RF'
		WHEN SUM(A.G_DH) > SUM(A.G_C) AND SUM(A.G_DH) > SUM(A.G_1B) AND SUM(A.G_DH) > SUM(A.G_2B) AND SUM(A.G_DH) > SUM(A.G_3B) AND SUM(A.G_DH) > SUM(A.G_SS) AND SUM(A.G_DH) > SUM(A.G_LF) AND SUM(A.G_DH) > SUM(A.G_CF) AND SUM(A.G_DH) > SUM(A.G_RF) AND SUM(A.G_DH) > SUM(A.G_P) THEN 'DH'
		WHEN SUM(A.G_P) > SUM(A.G_C) AND SUM(A.G_P) > SUM(A.G_1B) AND SUM(A.G_P) > SUM(A.G_2B) AND SUM(A.G_P) > SUM(A.G_3B) AND SUM(A.G_P) > SUM(A.G_SS) AND SUM(A.G_P) > SUM(A.G_LF) AND SUM(A.G_P) > SUM(A.G_CF) AND SUM(A.G_P) > SUM(A.G_RF) AND SUM(A.G_P) > SUM(A.G_DH) THEN 'PITCHER'
		ELSE NULL
	END AS MFP
from people p
inner join baseball.appearances a
on p.playerID = a.playerID
group by p.playerID
)

SELECT
	P.playerID,
	P.nameFirst,
	p.nameLast,
	p.bats,
	p.throws,
	b.walks,
	b.hits,
	b.ab,
	b.singles,
	b.doubles,
	b.triples,
	b.hr,
	b.hbp,
	b.sacf,
	b.runs,
	b.rbi,
	b.sb,
	bp.post_ab,
	bp.post_h,
	bp.post_games,
	f.assists,
	f.po,
	f.errors,
	a.as_games,
	aw.mvp,
	aw.gg,
	ws.ws_wins,
	wl.ws_losses,
	ap.gp,
	ap.mfp,
	h.firstyear,
	h.inducted
from PEOPLE P
LEFT JOIN BATTING B
	ON P.PLAYERID = B.PLAYERID
LEFT JOIN BATTING_POST BP
	ON P.PLAYERID = BP.PLAYERID
LEFT JOIN FIELDING F
	ON P.PLAYERID = F.PLAYERID
LEFT JOIN ALL_STAR A
	ON P.PLAYERID = A.PLAYERID
LEFT JOIN AWARDS AW
	ON P.PLAYERID = AW.PLAYERID
LEFT JOIN WS_WINS WS
	ON P.PLAYERID = WS.PLAYERID
LEFT JOIN WS_LOSSES WL
	ON P.PLAYERID = WL.PLAYERID
INNER JOIN HOF H
	ON P.PLAYERID = H.PLAYERID
LEFT JOIN APPEARANCES AP
	ON P.PLAYERID = AP.PLAYERID