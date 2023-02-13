// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract PoolLinks {

    struct ProjectLink{
        uint256 id;
        string imageURL;
        string twitterURL;
        string mediumURL;
        string websiteURL;
        string telegramURL;
        string discordURL;
    }


    mapping(uint256 => ProjectLink) public projectLinks;


    function addLinks(
        uint256 _id,
         string memory _imageURL,
        string memory _twitterURL,
        string memory _mediumURL,
        string memory _websiteURL,
        string memory _telegramURL,
        string memory _discordURL
    ) public {
         ProjectLink storage links = projectLinks[_id];

        links.imageURL = _imageURL;
         links.twitterURL = _twitterURL;
         links.mediumURL = _mediumURL;
         links.websiteURL = _websiteURL;
         links.telegramURL = _telegramURL;
         links.discordURL = _discordURL;
    }

     function getProjectLinks(uint256 id) view public
    returns (
        string memory,
        string memory,
        string memory,
        string memory,
        string memory,
        string memory){
            return(
         projectLinks[id].imageURL,
         projectLinks[id].twitterURL,
         projectLinks[id].mediumURL,
         projectLinks[id].websiteURL,
         projectLinks[id].telegramURL,
         projectLinks[id].discordURL
            );
        }


}