// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Crowdfunding {

    struct Campaign {
        string title;//Name of the campaign
        string description;//Brief description of the campaign.
        address benefactor;//Address receiving the funds.
        uint goal;//Fundraising goal in wei.
        uint deadline;//Timestamp when the campaign ends.
        uint amountRaised;//Total funds raised so far.
        bool isEnded;// Boolean indicating if the campaign has ended.
    }

    address public owner;
    Campaign[] public campaigns;
//Emitted when a campaign is created.
    event CampaignCreated(uint campaignId, string title, address benefactor, uint goal, uint deadline);
//Emitted when a donation is made.
    event DonationReceived(uint campaignId, address donor, uint amount);
//Emitted when a campaign ends and funds are transferred.
    event CampaignEnded(uint campaignId, uint amountRaised);
//Allows the contract to receive Ether directly
    event Received(address sender, uint amount);
//Handles calls to non-existent functions.
    event FallbackCalled(address sender, uint amount, bytes data);

//Restricts access to certain functions to the contract owner.
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
//Ensures the campaign exists.
    modifier campaignExists(uint _campaignId) {
        require(_campaignId < campaigns.length, "Campaign does not exist");
        _;
    }
//Ensures the campaign has not ended.
    modifier campaignNotEnded(uint _campaignId) {
        require(!campaigns[_campaignId].isEnded, "Campaign has ended");
        _;
    }
//Ensures actions are taken before the campaign deadline.
    modifier onlyBeforeDeadline(uint _campaignId) {
        require(block.timestamp < campaigns[_campaignId].deadline, "Campaign has ended");
        _;
    }

    constructor() {
        owner = msg.sender;
    }
   //Allows users to create a campaign by specifying the title, description, benefactor, goal, and duration. Calculates the deadline based on the duration
    function createCampaign(string memory _title, string memory _description, address _benefactor, uint _goal, uint _duration) public {
        require(_goal > 0, "Goal must be greater than zero");
        uint deadline = block.timestamp + _duration;
        campaigns.push(Campaign({
            title: _title,
            description: _description,
            benefactor: _benefactor,
            goal: _goal,
            deadline: deadline,
            amountRaised: 0,
            isEnded: false
        }));

        emit CampaignCreated(campaigns.length - 1, _title, _benefactor, _goal, deadline);
    }
// Allows users to donate to a campaign. The donation is added to amountRaised and must be before the campaign deadline.
    function donate(uint _campaignId) public payable campaignExists(_campaignId) campaignNotEnded(_campaignId) onlyBeforeDeadline(_campaignId) {
        Campaign storage campaign = campaigns[_campaignId];
        campaign.amountRaised += msg.value;
        emit DonationReceived(_campaignId, msg.sender, msg.value);
    }
//Ends the campaign and transfers the funds to the benefactor. Can only be called after the deadline.
    function endCampaign(uint _campaignId) public campaignExists(_campaignId) {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp >= campaign.deadline, "Campaign has not ended yet");
        require(!campaign.isEnded, "Campaign already ended");

        campaign.isEnded = true;
        payable(campaign.benefactor).transfer(campaign.amountRaised);
        emit CampaignEnded(_campaignId, campaign.amountRaised);
    }
// Allows the contract owner to withdraw any leftover funds in the contract.
    function withdrawLeftover() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {
        // Function to receive Ether. msg.data must be empty
        emit Received(msg.sender, msg.value);
    
    }

    fallback() external payable {
        // Fallback function to handle non-existent function calls
        emit FallbackCalled(msg.sender, msg.value, msg.data);
    }
}
