# Do backrun auctions protect traders?

1. Introduction
2. Markets and orders
3. Backrun games
4. Solution in free case
5. Monopoly
6. Some phase transitions

## Introduction

* One of the points of this is that the prices set by the arbitrageurs provide an incentive-compatible internal price oracle.
* A comparison with the case of batch auctions with uniform clearing price is natural. Our trades do not settle at a uniform price, but at equilibrium the initial marginal price is uniform across the batch. Larger trades are allowed to have larger price impact, and this slippage is used to pay for price information. In a UCP batch auction, the price impact of larger trades is effectively socialised across smaller trades.
* Of course, if this price oracle is used to price products outside the market under consideration, the incentive structure changes and the oracle may become unreliable.
* Another point is that if the marginal starting price does not depend on block position, we have a more predictable execution environment for traders.
* Changes in liquidity structure (that is, adding/removing liquidity from a pool or adding/cancelling limit orders in a book) are not part of our model. This can still be realistic, as a batch trading venue can allow liquidity changes in between, rather than in the middle of, batches.
* In an ideal world, liquidity traders can safely submit market orders to a trading venue and get at least as good an execution as they would on an external market. We find that in a situation of imperfect competition, this is not practical in our case.

## Markets

**Definition.** A *market* $\mathcal{M}$ consists of the data of a *demand function* $\delta_\mathcal{M}:U\rightarrow\mathbb{R}$ defined on an open subset $U\subseteq(0,\infty)$ which is piecewise $C^\infty$ (possibly with discontinuities) and monotone decreasing. The parameter of the function is called the *liquidity depth*. The market is said to be *smooth* if $\delta$ is everywhere $C^\infty$ and *invertible* if it is strictly monotone. (In fact, the relevant structure is that $U$ to be a neighbourhood of zero in an oriented 1-dimensional real affine space.)

The (graph of the) demand function is the aggregate demand curve of the market. Except for some technical details, our definition is that of \cite{milionis2023complexity}.

*Example.* The data of a market can be interpreted as follows. Suppose we have a risky asset $A$ and a num\'eraire $B$ that can be traded. Suppose that both assets are arbitrarily divisible and that a quantity $r$ of $A$ can be sold for $\hat{C}(r)$ of $B$, where $\hat{C}$ is some piecewise-differentiable function defined in a neighbourhood $U_0$ of $r=0$. Then setting $U=U_0+\omega$, where $\omega>0$ is chosen arbitrarily so that $U\subseteq(0,\infty)$, and $\delta(u):=d\hat{C}(r)/dr(u-\omega)$ defines a demand curve in the above sense. (It is reasonable to fix $\omega$ arbitrarily since in practice, liquidity of a market often cannot be completely exhausted by a single trade.)

*Example. (CFMM).* Let $f:(0,\infty)^2\rightarrow\mathbb{R}$ be a CFMM ($C^\infty$ with generically positive partial derivatives) and $\lambda\in\mathbb{R}$ a level. The level set $f^{-1}(\lambda)$ is an embedded submanifold of $(0,\infty)^2$ that projects diffeomorphically onto an open subset of either axis. Then there exists an open set $U\subseteq\mathbb{R}$ such that the projection $f^{-1}(\lambda)\rightarrow (0,\infty)$ admits a section $s:U\rightarrow f^{-1}(\lambda)$. Composing this section with the other projection gives a smooth real-valued function $P:U\rightarrow (0,\infty)$. Then $\delta_f:=-dP/dt$ defines a market on reserve set $U$ in the sense of Definition [above].

*Example. (Limit order book).* Given a snapshot of a limit order book with a set $(r_i,\ell_i)_{i\in I}$ of limit orders (with size $r>0$ denominated in the numeraire and limit $\ell>0$), we can recover a demand function by the formula
$$
\delta(u) := \sum_{i\in I,\ell_i\leq u}r_i
$$

Suppose given a market $\mathcal{M}$ and initial liquidity $a\in U_\mathcal{M}$. Then an order of size $r\in\mathbb{R}$ (we adopt the convention that a positive value means SELL $r$ units of $A$ while $r<0$ means BUY $-r$ units of $A$) settles for

$$
D(a,a+r) = \int_{a}^{a+r} \delta(u)du
$$

units of the numeraire.

*Example. (Reference market).* The highly liquid reference market $\mathcal{O}$ arises as a limiting case where $\delta:(0,\infty)\rightarrow\mathbb{R}$ is constant and the starting reserve $b\gg0$ is large compared to all other quantities under consideration.

**Definition.** *(Cost function).*  Generalising the case of the CFMM, if we fix an initial market depth $\omega\in U$ (or an initial price $p_0>0$) then we can define an *(absolute) cost function*
$$
D(x,y)=\int_x^y \delta(u)du 
$$
It is the value of $A$ one needs to sell on $\mathcal{M}$ to move the liquidity depth from $x$ to $y$. Note that $D(x,y)<0$ when $y<x$, indicating that to reduce the liquidity depth one must *buy* $A$.
  
The *relative* or *opportunity cost* function at $\omega_0\in U$ is the quantity
$$
C_{\omega_0}(\omega) = \delta(\omega_0)(\omega-\omega_0) - D(\omega_0,\omega).
$$
Both terms have the same sign, and if $\omega>\omega_0$ (resp. $\omega<\omega_0$), the linear term (resp. nonlinear term) dominates. Hence this function is valued in non-negative reals with a minimum at $C_{\omega_0}(\omega_0)= 0$. It is differentiable with derivative $\delta(\omega_0)-\delta(\omega)$.

Note that the opportunity costs at different liquidity depths $\omega_0,\omega_1$ differ by a linear term with gradient $\delta(\omega_1)-\delta(\omega_0)$.

*Remark.* The quantity $C_{\omega_0}$ can be interpreted as a surplus supply or demand of the risky asset $A$. If $\omega_1>\omega_\mathcal{O}$, then it is a surplus supply (of the risky asset), i.e. $\mathcal{M}$ will sell this amount below the odds. Correspondingly, if $\omega<\omega_\mathcal{O}$, it is a surplus demand. 

* We also need to discuss limit orders, partial fills, and fill-or-kill

*Remark.* The intuition for this work comes from the case that $\mathcal{M}$ is a CFMM DEX. However, the generality of the model is an arbitrary market defined in terms of a "market impact function." For example, on a LOB exchange an arbitrageur can effect their backrun by submitting a large partial fill order with a limit at the target price.

## Backrun game

We consider a game of $N$ players $X_1,\ldots,X_n$ attempting to insert arbitrage transactions on a market $\mathcal{M}$ between assets $A$ and $B$ (the numéraire). We suppose that a batch of $K$ limit orders $\tau_1,\ldots,\tau_K$, $\tau_i=(r_i,\ell_i)$ (size $r\in\mathbb{R}$ and limit price $\ell\in[0,\infty]$) are to be processed in some order $\sigma\in\Sigma_K$. We interpret $\sigma$ as a permutation on $[K]_+=\{0\}\sqcup [K]$ by fixing the basepoint.

Suppose given an *allocation* $\phi:[K]_+\rightarrow[N]$ of trades and top-of-block (ToB) to players. We say the game is *free* if $\phi$ is injective (or if $\phi$ is random, $\phi$ is injective with unit probability). Then to each player $i$, we can associate a set $\phi^{-1}(i)$ of trades which is either a singleton or empty.

In play, each player $X_i$ chooses a *target price* $p_i$. (If the market is invertible, it is equivalent to choose a target *depth* $u$; this makes some of the formulas easier to interpret. If the market isn't invertible, for example because $\delta$ has discontinuities, then depth is the correct parameter to choose.) If $\phi^{-1}(i)$ is nonempty, the smallest trade (either BUY or SELL, as appropriate) possible such that the marginal price after the trade is $p_i$, is inserted after $\tau_{\sigma\phi^{-1}(i)}$. That is, the action space for each player $X_i$ is $\mathcal{A}_i=\mathbb{R}$. 

All players may also trade on a reference market $\mathcal{O}$ at a constant price $p_\mathcal{O}$.

The payout for doing a trade of size $r$ on $\mathcal{M}$ followed by a trade of size $-r$ on $\mathcal{O}$ is

$$
\int_{a}^{a+r}(\delta_\mathcal{M}(u)-p_\mathcal{O})du = \int_a^{a+r}\delta_\mathcal{M}(u)du -p_\mathcal{O}\cdot r.
$$

We call the nonlinear term $D(a,a+r)$.

For simplicity we assume that utility for players is measured only in terms of asset $B$. That is, players do not gain utility from holding $A$ in inventory. To gain utility, players must complete a pure profit cyclic arbitrage as above.


### Information structure

The parameter space for the backrun game has the form 

$$
\mathcal{H}=\coprod_{N\in\mathbb{N}}\mathcal{H}_N =\coprod_{N\in\mathbb{N}}
\coprod_{K\in\mathbb{N}} N\times (\mathbb{R}\times N\times K)^K.
$$
$$
\mathcal{H}_N=
\coprod_{K\in\mathbb{N}} N\times (\mathbb{R}\times N\times K)^K.
$$

In words, once the number of players and trades, and hence a factor in the above decomposition, are fixed, all that remains is to specify the assignment

$$
k \mapsto (\tau_k, \phi(k), \sigma(k))
$$

of a trade, backrunner, and block position to each index $k=1,\ldots,K$.

For simplicity, we will assume that the number $N$ of players is always known to all players. No effective generality is lost by this restriction, since any situation with an unknown number of players can be approximated by a game with a fixed large number of players whose probability to be able to participate (i.e. appear in the image of the allocation function $\phi$) is unknown, and possibly $0$.

An *information structure* on a backrun game with $N$ players is a tuple of functions $h_i:\mathcal{H}_N\rightarrow\Omega_i$, $i=1,\ldots,N$. The interpretation is that for each realisation $\omega\in\mathcal{H}_N$, player $i$ knows $h_i(\omega)$ exactly and a prior distribution on $h_i^{-1}(h_i(\omega))$ when he chooses his action. In other words, an information structure together with player priors defines (a version of) a static Bayes game of incomplete information.

*Remark.* The original formulation of Bayesian game considers only a single distribution on the total configuration space $\Omega$, with all players having partial views of that space. We can recover a structure like this by constructing a product distribution on $\mathcal{H}_N^N$ (with arbitrary marginal distributions on $\Omega_N$).

Examples of information structures:

* Complete information: $\Omega_i=\mathcal{H}_N$ for all $i$.
* Number of orders. $\Omega_i=\mathbb{N}$, $h_i(K,\ldots)=K$.
* Number and sequence order of orders.

*Remark.* In non-free backrun games, it is also possible to consider more complex action spaces where players can choose different target prices for different slots. The possible structures of these action spaces depend on the information structure, because the player will then need to say something about which slot gets which price. For simplicity, I consider only the "uniform" case where the player must set a single price for the whole batch. 

As well as being conceptually straightforward, I think this is likely to be the most attractive structure in practice.

* If $\tau_i$ are i.i.d. then we can apply a relabelling $\sigma'\in\Sigma_K$ without changing the dynamics. The relabelling can even be random. In particular, we can apply $\sigma^{-1}$ and hence w.l.o.g. assume $\tau_i$ are indexed in the order they appear in the block.

## Solution: free case

We first exhibit equilibria in the case of perfect information. It is not hard to see that when the market is invertible, each participating player has a unique dominating strategy. (Since we have perfect information, players know in advance whether or not they are participating.)

Indeed, suppose the reserve at the start of slot $i$ is $a_i$. If $i>0$, this occurs immediately after the $i$th trade $\tau_{\sigma(i)}$. The objective is to maximise the integral

$$
\int_{a_i}^{a_i+r}(p_\mathcal{M}(u)-p_\mathcal{O})du.
$$

If $p_\mathcal{M}(a_i) \geq p_\mathcal{O}$ (resp. $p_\mathcal{M}(a_i) \leq p_\mathcal{O}$), then this function is a monotone increasing (resp. decreasing) function of $r$ for $r<p_\mathcal{M}^{-1}(p_\mathcal{O})$ (resp. $r>p_\mathcal{M}^{-1}(p_\mathcal{O})$). The value $c=p_\mathcal{M}^{-1}(p_\mathcal{O})$ is called the *critical reserve*. Note that it is defined without reference to any function of the information space $\mathcal{H}$. If the market is invertible, the critical reserve is uniquely determined.

Therefore the maximum is obtained at $r=c-a_i$ with target price $p_i=p_\mathcal{O}$. Since this target price does not depend on the actions of other players or on any of the moduli of the game itself, this is a dominating strategy for all players and all (free) information structures.





## Generalisations

### Interpretation as diffuse large $N$ limit


The free game models the situation where each agent has a strategy of horizon of one slot. That is, for each player $X$, given that $X$ is allocated at least one slot, $X$ is almost surely allocated exactly one slot. This approximates a limit of games whose allocation function $\phi$ is distributed as a product of uniform distributions as $N\rightarrow\infty$ (or at least whose point masses are $\mathcal{O}(N)$).

* We consider the limit in the case that the allocations $\phi_0,\ldots,\phi_K$ are independent and identically distributed.
* Project the game to a game of 2 players by collapsing the last $N-1$ players to a single player. Then the allocation distribution is controlled by a single parameter $0\leq w\leq 1$, the probability that a given slot is assigned to player $1$. (In applications, we may imagine $w$ as the "stake" or "voting weight" of player $1$.)
* We will need to assume that the payoff function has finite $L^1$ norm over $\mathcal{H}_N$. It is enough to assume that the order distribution is supported on a bounded subset of $\mathbb{R}\times(0,1]$, or that trades cannot exhaust the liquidity $U$ (by exiting $U$).
* Suppose that $w_n$ is $\mathcal{O}(n)$ as $n\rightarrow\infty$. Then
  $$
  \mathbb{U}(p_1) = w\cdot\int_{a}^{p^{-1}(p_1)}(p_\mathcal{M}(u)-p_\mathcal{O})du +  \mathcal{O}(w^2)
  $$
  where $F(p_1)=\mathcal{O}(w^2)$. So by continuity, for any $p_1\neq p_\mathcal{O}$ we have
  \begin{align}
  \frac{1}{w}(\mathbb{U}(p_\mathcal{O})-\mathbb{U}(p_1)) &= \int_{p^{-1}(p_1)}^{p^{-1}(p_\mathcal{O})}(p_\mathcal{M}(u)-p_\mathcal{O})du + \mathcal{O}(w)\\
  &>0 \text{ for small }w.
  \end{align}
  Therefore $p_\mathcal{O}$ is the unique dominating strategy for large $n$.
* Unfortunately, this is nonsense because no one has to choose a strategy $p_1$ uniformly for all $n$. In fact it is possible to show that unless order flow is perfectly balanced in expectation, for all $w$ there exists a $p_1\neq p_\mathcal{O}$ for which the proceeds of manipulation exceed $2/w$ times the cost.

The best we can hope for is that the optimal $\hat{p}(w)$ converges to $p_\mathcal{O}$ as $w\rightarrow 0_+$.

### Two slot case

Consider the case $K=1$, so that there are two slots, top of block and backrun. In this case a monopolist simply has an opportunity to sandwich one trade.



A player choosing $\omega$ as target pays an opportunity cost of $C_\mathcal{O}(\omega)$ once for each slot they are allocated, as compared with choosing the oracle passthrough strategy. Conversely, a player who sets the state to $\omega_\mathcal{O}$ from a starting state of $\omega$ can earn $C_\mathcal{O}(\omega)$.

Suppose that Player 1 is allocated slot zero, resp. one, independently with probability $w_i$, $i=0,1$. Then the payoffs for a strategy $\omega$ are given by the formula
$$
\begin{align}
w_0(1-w_1)(C_\mathcal{O}(\omega_0)-C_\mathcal{O}(\omega)) + (1-w_0)w_1(C_\mathcal{O}(\omega_1)-C_\mathcal{O}(\omega)) \\ + w_0w_1(C_\mathcal{O}(\omega_0)+C_\mathcal{O}(\omega+r_1)-2C_\mathcal{O}(\omega))
\end{align}
$$
where $r_1$ is the size of the order in slot $1$ (which for now we assume has no limit) and $\omega_1$ is the strategy chosen by the other player. (It may be appropriate to consider $\omega_1$ as a random variable and take expectations of $C_\mathcal{O}(\omega_1)$.)

Differentiating with respect to $\omega$, we find that dependence on the only term controlled by the actions of other players drops out, and we are left with the function
$$
w_0w_1C'_\mathcal{O}(\omega+r_1)-(w_0+w_1)C'_\mathcal{O}(\omega),
$$
equivalently,
$$
w_0w_1(\pm\delta(\omega+r)-p_\mathcal{O}) - (w_0+w_1)(\pm\delta(\omega) - p_\mathcal{O}).
$$
In the case of monopoly, $w_0=w_1=1$ and we're left with $\delta(\omega+r)-2\delta(\omega)+p_\mathcal{O}$. This vanishes with positive $\omega$-derivative at $r=0, \omega=\omega_\mathcal{O}$, so the oracle passthrough strategy is actually a local *minimum*.

* If $\delta$ is convex, we have $\delta'(\omega+r)>\delta'(\omega)>2\delta'(\omega)$ for all $r\geq 0$. So there are no local maxima for sell orders.
* For $r<0$ there may be some regions where $\delta'(\omega+r)<2\delta'(\omega)$.

In perfect competition, $w_0=w_1=0$ and payoffs have gradient $\delta(\omega)-p_\mathcal{O}$ which vanishes at $\omega=p_\mathcal{O}$. Since $\delta$ is monotone decreasing, this is a maximum, as expected.

*Example. (CPMM).* If $\mathcal{M}$ is a CPMM, the zeros of $\delta(\omega+r)-2\delta(\omega)+p_\mathcal{O}$ form a plane quartic passing through $(\omega_0,r)\in\mathbb{R}^2$.


### Repeated batches

Consider a repeated version of the backrun game where the same $N$ players play $M\in\mathbb{N}\sqcup\{\infty\}$ times (with $\vec{\tau},\sigma,\phi$ re-rolled each play).
In this game:
* It is possible for players to learn something about the other players in the course of the game.
* There are (uncoupled) Nash equilibria in which players spontaneously coordinate to fix prices.
* In the large $M$ limit, exit scams can occur.
* For realism, the repeated game should also allow liquidity changes (i.e. changes in $p_\mathcal{M}$ and initial liquidity) between rounds. One can choose whether or not player know about up-to-date liquidity parameters when they choose their moves; if not, payoff analysis is substantially complicated.

The qualitative difference between scaling the number of rounds and scaling the number of transactions in the batch is that the order of rounds is known ahead of time and that players learn of other players moves a posteriori (though of course we could assume even further that past moves are shielded).

The conclusions about the free game still apply under the correct conditions (many players, high discount rate).

## Monopoly

We now consider a case that is in a sense "opposite" to the free game played before. A player $X_i$ is a *monopolist* if they know that the allocation $\phi:K\rightarrow N$ is constant with value $i$. That is, $h_i:\mathcal{H}_N\rightarrow\Omega_i$ factors the projection $(K,\phi):\mathcal{H}_N\rightarrow\coprod_{K}N^{K_+}$ and $\phi\equiv i$ almost surely. If the $i$th player is a monopolist, then we may as well assume $N=i=1$, and our game reduces to a decision problem.

The payoffs for a strategy $\omega$  now look like
$$
|C_\mathcal{O}(\omega_0)|+|C_\mathcal{O}(\omega+r_1)|-2|C_\mathcal{O}(\omega)|.
$$
The first term is constant and hence can be ignored for the purposes of finding optima. The function has a concave bend at $\omega_0$ and a convex one at $\omega_0-r_1$. When $r_1\rightarrow \omega_0$, they merge into a single convex bend.

### Buy side

Suppose $r<0$. Then the regions of differentiability are $(0,\omega_\mathcal{O})$, $(\omega_\mathcal{O},\omega_\mathcal{O}-r)$, $(\omega_\mathcal{O},\infty)$.

* On $(\omega_\mathcal{O},\omega_\mathcal{O}-r)$ the derivative is $\delta(\omega+r)+2\delta(\omega)+3p_\mathcal{O}>0$.
* For $\omega>\omega_\mathcal{O}-r$ the derivative is $2\delta(\omega)-\delta(\omega+r)$. This could have either sign at any point. If it is negative at $\omega=\omega_\mathcal{O}-r$, meaning that the price impact of a sell of size $-r$ is worse than $50\%$, then $\omega_\mathcal{O}-r$ is a  
