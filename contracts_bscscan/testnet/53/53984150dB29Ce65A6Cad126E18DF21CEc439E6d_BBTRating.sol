// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./Ownable.sol";

contract BBTRating is Ownable {
    
    struct Profile {
        uint id;
        string name;
        uint reviewsCount;
        uint sumRating;
        mapping(address => bool) hasReviewed;
    }

    event ProfileAdded(
        uint id,
        string name
    );

    event ProfileReviewed(
        uint id,
        uint avgRating
    );

    uint numProfiles;
    mapping(uint => Profile) profiles;
    uint public profileCount = 0;

    function addProfile(string memory _name) public onlyOwner {
        require(keccak256(bytes(_name)) != keccak256(""), "The name property is required.");

        Profile storage p = profiles[numProfiles++];
        
            p.id = profileCount;
            p.name = _name;
            p.reviewsCount = 0;
            p.sumRating = 0;

            profileCount++;
    }
        
    function addReview(uint _profileId, uint8 _rating) public {
        Profile storage profile = profiles[_profileId];

        require(keccak256(bytes(profile.name)) != keccak256(""), "Profile not found.");
        require(_rating >= 0 && _rating <= 5, "Rating is out of range.");
        require(!profile.hasReviewed[msg.sender], "This address already reviewed this profile.");

        profile.sumRating += _rating * 10;
        profile.hasReviewed[msg.sender] = true;
        profile.reviewsCount++;

        emit ProfileReviewed(profile.id, profile.sumRating / profile.reviewsCount);
    }
    
    function getProfile(uint profileId) public view returns (uint id, string memory name, uint avgRating, uint reviewsCount) {
        Profile storage profile = profiles[profileId];
        uint _avgRating = 0;

        if(profile.reviewsCount > 0)
            _avgRating = profile.sumRating / profile.reviewsCount;
        
        return (
            profile.id,
            profile.name,
            _avgRating,
            profile.reviewsCount
        );
    }
}