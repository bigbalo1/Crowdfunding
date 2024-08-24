// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Crowdfunding {

    struct Campaign {
        string title;
        string description;
        address benefactor;
        uint goal;
        uint deadline;
        uint amountRaised;
        bool isEnded;
    }

    address public owner;
    Campaign[] public campaigns;

    event CampaignCreated(uint campaignId, string title, address benefactor, uint goal, uint deadline);
    event DonationReceived(uint campaignId, address donor, uint amount);
    event CampaignEnded(uint campaignId, uint amountRaised);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier campaignExists(uint _campaignId) {
        require(_campaignId < campaigns.length, "Campaign does not exist");
        _;
    }

    modifier campaignNotEnded(uint _campaignId) {
        require(!campaigns[_campaignId].isEnded, "Campaign has ended");
        _;
    }

    modifier onlyBeforeDeadline(uint _campaignId) {
        require(block.timestamp < campaigns[_campaignId].deadline, "Campaign has ended");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

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

    function donate(uint _campaignId) public payable campaignExists(_campaignId) campaignNotEnded(_campaignId) onlyBeforeDeadline(_campaignId) {
        Campaign storage campaign = campaigns[_campaignId];
        campaign.amountRaised += msg.value;
        emit DonationReceived(_campaignId, msg.sender, msg.value);
    }

    function endCampaign(uint _campaignId) public campaignExists(_campaignId) {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp >= campaign.deadline, "Campaign has not ended yet");
        require(!campaign.isEnded, "Campaign already ended");

        campaign.isEnded = true;
        payable(campaign.benefactor).transfer(campaign.amountRaised);
        emit CampaignEnded(_campaignId, campaign.amountRaised);
    }

    function withdrawLeftover() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {
        // Function to receive Ether. msg.data must be empty
    }

    fallback() external payable {
        // Fallback function to handle non-existent function calls
    }
}
