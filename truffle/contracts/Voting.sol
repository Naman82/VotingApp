//SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract Voting{
    uint i;
    address payable public ElectionCommissionHead;
    constructor() payable{
        ElectionCommissionHead=payable(msg.sender);
    }

    struct PartyInfo{
        address partyAddress;
        string partyName;
        uint voteCount;
        bool isFeePaid;
    }

    PartyInfo[10] public parties;

    mapping(uint=>PartyInfo) ElectionParty;

    function alreadyRegistered() private view returns(bool){
        for(uint k=0; k<parties.length; k++){
            if(parties[k].partyAddress == msg.sender){
                return true;
            }
        }
        return false;
    }

    function isSameName(string memory _partyName) private view returns(bool){
        for(uint y=0; y<parties.length; y++){
            if(keccak256(abi.encodePacked(parties[y].partyName)) == keccak256(abi.encodePacked(_partyName))){
                return true;
            }
        }
        return false;
    }


    function payFee(string memory _partyName) public payable{
        require(msg.sender != ElectionCommissionHead, " ElectionCommissionHead won't pay any fees");
        require(msg.value == 1 ether , "Pay fees");
        require(alreadyRegistered() == false,"Party is already registered");
        require(isSameName(_partyName) == false, "Party with same name already exists");
        parties[i].partyAddress = msg.sender;
        parties[i].partyName = _partyName;
        ElectionParty[i] = parties[i];
        parties[i].isFeePaid = true;
        i++;
    }

    function checkBalance() public view returns(uint){
        return address(this).balance;
    }

    function transferElectionAmount() public {
        require(msg.sender == ElectionCommissionHead,"ElectionCommission will able to transfer election amount");
        uint totalAmount = address(this).balance;
        ElectionCommissionHead.transfer(totalAmount);
    }

    function checkBalanceOfElectionCommissionHead() public view returns(uint){
        return ElectionCommissionHead.balance;
    }

    //aadhar card number based voting

        bytes32[]  voterHash;
        address[] voterAddress;
    

    // voterInfo[] public voter;

    function alreadyVoted() private view returns(bool){
        for(uint l=0; l<voterAddress.length; l++){
            if(voterAddress[l]==msg.sender){
                return true;
            }
        }
        return false;
    }

    function isPartyList() private view returns(bool){
        if(parties[0].partyAddress == address(0)){
            return false;
        }
        return true;
    }

    //age will be checked by aadharnumber validation api

    function vote(uint _aadharNumber, uint choice) public {
        require(alreadyVoted() == false, "you have already voted once ");
        require(isPartyList() == true, "No parties have participated in election");
        voterAddress.push(msg.sender);
        voterHash.push(sha256(abi.encodePacked(msg.sender, _aadharNumber)));
        parties[choice].voteCount = parties[choice].voteCount + 1;
    }

    //result of the election

    function result() public view returns(string memory, uint){
        require(msg.sender == ElectionCommissionHead,"ElectionCommission will be able to declare Result");
        uint maxVoteCount = parties[0].voteCount;
        string memory winner = parties[0].partyName;
        for( uint x=1; x<parties.length; x++){
            if(parties[x].voteCount>maxVoteCount){
                maxVoteCount = parties[x].voteCount;
                winner = parties[x].partyName;
            }
        }
        return (winner,maxVoteCount);
    }
    
}