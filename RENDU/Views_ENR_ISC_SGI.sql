USE Tournois_eSport
GO

CREATE VIEW V_Tournois_eSport AS 
Select a.*, b.*, c.*, d.*,  e.*,  f.*,  g.*,  h.*,  i.*,  j.*,  k.*,  l.*, m.*,  n.*,  o.*,  p.*
from
(Select COUNT(*) as Joueurs from dbo.Players)a,
(Select COUNT(*) as Equipes from dbo.Teams)b,
(Select COUNT(*) as Entraineurs from dbo.Coachs)c,
(Select COUNT(*) as Coach_Team from dbo.Train)d,
(Select COUNT(*) as Organisations from dbo.Organizations)e,
(Select COUNT(*) as Sponsors from dbo.Sponsors)f,
(Select COUNT(*) as Organisation_Sponsor from dbo.Sponsor)g,
(Select COUNT(*) as Niveaux from dbo.Levels)h,
(Select COUNT(*) as Tournois from dbo.Tournaments)i,
(Select COUNT(*) as Sponsor_Tournament from dbo.Tournaments)j,
(Select COUNT(*) as Plateformes from dbo.Platforms)k,
(Select COUNT(*) as Jeux from dbo.Games)l,
(Select COUNT(*) as Matchs from dbo.Matches)m,
(Select COUNT(*) as Diffusions from dbo.Broadcasts)n,
(Select COUNT(*) as Match_Diffusion from dbo.Broadcast)o,
(Select COUNT(*) as Commentateurs from dbo.Commentators)p


