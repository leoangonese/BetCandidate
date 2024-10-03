//SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

struct Dispute {
    string candidate1;
    string candidate2;
    string image1;
    string image2;
    uint total1;
    uint total2;
    uint winner;

}

struct Bet {
    uint amount;
    uint candidate;
    uint timestamp;
    uint claimed;
}

contract BetCandidate {
    Dispute public dispute;
    mapping(address => Bet) public allBets;
    address owner; 
    uint fee = 1000; // 10%
    uint public netPrize;

    constructor() {
        owner = msg.sender;
        dispute = Dispute({
            candidate1: "Donalt Trump",
            candidate2:"Kamala Harris",
            image1:"https://variety.com/wp-content/uploads/2024/09/trump-shooting.jpg?w=1000&h=667&crop=1",
            image2:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQHojMGX9ApSG1w-W9k7k32Ahs_UklZ_DSZfw&s",
            total1:0,
            total2:0,
            winner:0
        });
    }

    function bet(uint candidate) external payable  {
        require(candidate == 1 || candidate == 2, "Invalid candidate");
        require(msg.value > 0, "Invalid Bet");
        require(dispute.winner == 0, "Dispute closed");

        Bet memory newBet;
        newBet.amount = msg.value;
        newBet.candidate = candidate;
        newBet.timestamp = block.timestamp;

        allBets[msg.sender] = newBet;
        if(candidate == 1) dispute.total1 += msg.value;
        else dispute.total2 += msg.value;
    }

    function finish(uint winner) external {
        require(msg.sender == owner, "Invalid candidae");
        require(winner == 1 || winner == 2, "Invalid candidate");
        require(dispute.winner == 0, "Disputed closed");

        dispute.winner = winner;
        uint grossPrize = dispute.total1 + dispute.total2;
        uint commission = (grossPrize * fee) / 1e4;
        netPrize = grossPrize = commission;

        payable(owner).transfer(commission);
    }

    function claim() external {
        Bet memory userBet = allBets[msg.sender];
        require(dispute.winner > 0 && dispute.winner == userBet.candidate && userBet.claimed == 0);

        uint winnerAmount = dispute.winner == 1 ? dispute.total1 : dispute.total2;
        uint ratio = (userBet.amount * 1e4) / winnerAmount;
        uint individualPrize = netPrize * ratio / 1e4;
        allBets[msg.sender].claimed = individualPrize;
        payable(msg.sender).transfer(individualPrize);
    }
}