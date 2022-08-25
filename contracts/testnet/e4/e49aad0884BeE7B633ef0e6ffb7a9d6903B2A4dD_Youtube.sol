// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Replys.sol";

contract Youtube is Replys {
    // Change personal information

    function changeName(string memory _newUserName) public {
        require(userId[msg.sender] != 0);
        uint256 _userId = userId[msg.sender];
        users[_userId].userName = _newUserName;
    }

    function changeProfileImag(string memory _profileImag) public {
        require(userId[msg.sender] != 0);

        uint256 _userId = userId[msg.sender];
        users[_userId].profileImag = _profileImag;
    }

    function saveVideo(uint256 _videoId) public {
        require(userId[msg.sender] != 0);

        uint256 _userId = userId[msg.sender];

        if (users[_userId].videoSaved.length == 0) {
            users[_userId].videoSaved.push(_videoId);
        } else {
            // --------- check if video already saved ---------------- :
            uint256 isVideoSaved;
            for (uint256 i = 0; i < users[_userId].videoSaved.length; i++) {
                if (users[_userId].videoSaved[i] == _videoId) {
                    isVideoSaved++;
                }
            }

            if (isVideoSaved == 0) {
                users[_userId].videoSaved.push(_videoId);
            }
        }
    }

    function deleteSavedVideo(uint256 _videoId) public {
        require(userId[msg.sender] != 0);

        uint256 _userId = userId[msg.sender];

        for (uint256 i = 0; i < users[_userId].videoSaved.length; i++) {
            if (users[_userId].videoSaved[i] == _videoId) {
                delete (users[_userId].videoSaved[i]);
            }
        }
    }

    function deletUser(address _userAddres) public {
        require(msg.sender == admin);
        uint256 _userId = userId[_userAddres];

        if (users[_userId].userVideos.length > 0) {
            for (uint256 i = 0; i < users[_userId].userVideos.length; i++) {
                delete (videos[users[_userId].userVideos[i]]);
            }
        }

        delete (users[_userId]);
        delete (userId[_userAddres]);
    }

    function changeAdmin(address _newAdmin) public {
        require(msg.sender == admin);
        admin = _newAdmin;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract YoutubeData {
    address public admin;

    constructor() {
        admin = msg.sender;
    }

    struct user {
        uint256 id;
        string userName;
        address userAddress;
        string profileImag;
        uint256[] userVideos;
        uint256[] videoSaved;
    }
    struct reply {
        uint256 id;
        address owner;
        string reply;
        uint256 timestamp;
        address[] likes;
        address[] dislike;
    }
    struct comment {
        uint256 id;
        address owner;
        string comment;
        uint256 timestamp;
        address[] likes;
        address[] dislike;
        uint256[] repliesIds;
    }

    struct video {
        uint256 id;
        string videoHash;
        string videoTayp;
        string videoTitle;
        uint256 timestamp;
        address owner;
        address[] likes;
        address[] dislike;
        uint256[] commentsIds;
    }

    uint256 public usersCount;
    uint256 public videosCount;

    mapping(address => uint256) public userId;
    mapping(uint256 => user) public users;
    mapping(uint256 => video) public videos;
    mapping(uint256 => mapping(uint256 => comment)) videoComments;
    mapping(uint256 => mapping(uint256 => mapping(uint256 => reply))) commentReplies;

    function signUp(string memory _userName, string memory _profileImag)
        public
    {
        require(userId[msg.sender] == 0);

        usersCount++;

        user storage _user = users[usersCount];
        _user.id = usersCount;
        _user.userName = _userName;
        _user.userAddress = msg.sender;
        _user.profileImag = _profileImag;

        userId[msg.sender] = usersCount;
    }

    function _alreadyReact(address[] memory _interactors, address _owner)
        public
        pure
        returns (uint256 _indexOfOwner)
    {
        if (_interactors.length > 0) {
            for (uint256 i = 0; i < _interactors.length; i++) {
                if (_interactors[i] == _owner) {
                    _indexOfOwner = i + 1;
                }
            }
        }

        return _indexOfOwner;
    }

    function getUserById(uint256 _userId) public view returns (user memory) {
        return users[_userId];
    }

    function getUserByAddress(address _userAddress)
        public
        view
        returns (user memory)
    {
        uint256 _userId = userId[_userAddress];
        return users[_userId];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./YoutubeData.sol";

contract Videos is YoutubeData {
    //  -------------------- Video functions ---------------------:

    function downloadVideo(string memory _Hash, string memory _Tayp, string memory _title) public {
        require(userId[msg.sender] != 0);
        videosCount++;
        video storage _video = videos[videosCount];
        _video.id = videosCount;
        _video.videoHash = _Hash;
        _video.videoTayp = _Tayp;
        _video.videoTitle = _title;
        _video.timestamp = block.timestamp;
        _video.owner = msg.sender;

        users[userId[msg.sender]].userVideos.push(videosCount);
    }

    function deleteVideo(uint256 _videoId) public {
        require(videos[_videoId].owner == msg.sender);
        delete (videos[_videoId]);
        for (
            uint256 i = 0;
            i < users[userId[msg.sender]].userVideos.length;
            i++
        ) {
            if (users[userId[msg.sender]].userVideos[i] == _videoId) {
                delete (users[userId[msg.sender]].userVideos[i]);
            }
        }
    }

    function likeVideo(uint256 _videoId) public {
        require(userId[msg.sender] != 0);
        uint256 _LikesIndex = _alreadyReact(videos[_videoId].likes, msg.sender);
        uint256 _DislikeIndex = _alreadyReact(
            videos[_videoId].dislike,
            msg.sender
        );
        if (_LikesIndex == 0) {
            videos[_videoId].likes.push(msg.sender);

            if (_DislikeIndex > 0) {
                delete (videos[_videoId].dislike[_DislikeIndex - 1]);
            }
        } else {
            delete (videos[_videoId].likes[_LikesIndex - 1]);
        }
    }

    function dislikeVideo(uint256 _videoId) public {
        uint256 _LikesIndex = _alreadyReact(videos[_videoId].likes, msg.sender);
        uint256 _DislikeIndex = _alreadyReact(
            videos[_videoId].dislike,
            msg.sender
        );

        if (_DislikeIndex == 0) {
            videos[_videoId].dislike.push(msg.sender);
            if (_LikesIndex > 0) {
                delete (videos[_videoId].likes[_LikesIndex - 1]);
            }
        } else {
            delete (videos[_videoId].dislike[_DislikeIndex - 1]);
        }
    }

    function getVideo(uint256 _VideoId) public view returns (video memory) {
        return videos[_VideoId];
    }

    function functionPublic() public pure returns (uint256[] memory) {
        uint256[] memory newArray;

        return newArray;
    }

    function getAllVideos() public view returns (video[] memory) {
        video[] memory _AllVideos = new video[](videosCount);

        for (uint256 i = 1; i <= videosCount; i++) {
            video memory _video = getVideo(i);
            _AllVideos[i - 1] = _video;
        }

        return _AllVideos;
    }

    function _getAllIdsVideosByType(string memory _videoType)
        private
        view
        returns (uint256[] memory)
    {
        // ...........get length first :
        uint256 _length;
        for (uint256 i = 1; i <= videosCount; i++) {
            video memory _video = getVideo(i);
            if (
                keccak256(abi.encodePacked(_video.videoTayp)) ==
                keccak256(abi.encodePacked(_videoType))
            ) {
                _length++;
            }
        }
        uint256[] memory _videosId = new uint256[](_length);
        uint256 _index;
        if (_length > 0) {
            for (uint256 i = 1; i <= videosCount; i++) {
                video memory _video = getVideo(i);
                if (
                    keccak256(abi.encodePacked(_video.videoTayp)) ==
                    keccak256(abi.encodePacked(_videoType))
                ) {
                    _videosId[_index] = _video.id;
                    _index++;
                }
            }
        }
        return _videosId;
    }

    function getAllVideoByType(string memory _videoType)
        public
        view
        returns (video[] memory)
    {
        uint256[] memory _videosId = _getAllIdsVideosByType(_videoType);

        video[] memory _AllVideos = new video[](_videosId.length);

        for (uint256 i = 0; i < _videosId.length; i++) {
            video memory _video = getVideo(_videosId[i]);
            _AllVideos[i] = _video;
        }
        return _AllVideos;
    }

    function getUserVideosById(uint256 _userId)
        public
        view
        returns (video[] memory)
    {
        user memory _user = getUserById(_userId);
        require(_user.userVideos.length > 0);
        video[] memory _AllVideos = new video[](_user.userVideos.length);
        for (uint256 i = 0; i < _user.userVideos.length; i++) {
            video memory _video = getVideo(_user.userVideos[i]);

            _AllVideos[i] = _video;
        }

        return _AllVideos;
    }

    function getUserVideosByAddress(address _userAddress)
        public
        view
        returns (video[] memory)
    {
        user memory _user = getUserByAddress(_userAddress);
        require(_user.userVideos.length > 0);
        video[] memory _AllVideos = new video[](_user.userVideos.length);
        for (uint256 i = 0; i < _user.userVideos.length; i++) {
            video memory _video = getVideo(_user.userVideos[i]);

            _AllVideos[i] = _video;
        }

        return _AllVideos;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Comments.sol";

contract Replys is Comments {
    //  -------------------- Reply functions ---------------------:
    function addReply(
        uint256 _videoId,
        uint256 _commentId,
        string memory _replyComent
    ) public {
        require(userId[msg.sender] != 0);

        uint256 _replyId = videoComments[_videoId][_commentId]
            .repliesIds
            .length + 1;

        reply storage _reply = commentReplies[_videoId][_commentId][_replyId];

        _reply.id = _replyId;
        _reply.owner = msg.sender;
        _reply.reply = _replyComent;
        _reply.timestamp = block.timestamp;

        videoComments[_videoId][_commentId].repliesIds.push(_replyId);
    }

    function getCommentReply(
        uint256 _videoId,
        uint256 _commentId,
        uint256 _replyId
    ) public view returns (reply memory) {
        return commentReplies[_videoId][_commentId][_replyId];
    }

    function deletReply(
        uint256 _videoId,
        uint256 _commentId,
        uint256 _replyId
    ) public {
        require(userId[msg.sender] != 0);
        require(
            commentReplies[_videoId][_commentId][_replyId].owner ==
                msg.sender ||
                videos[_videoId].owner == msg.sender
        );
        require(_commentId > 0 && _videoId > 0 && _replyId > 0);

        delete (commentReplies[_videoId][_commentId][_replyId]);

        for (
            uint256 i = 0;
            i < videoComments[_videoId][_commentId].repliesIds.length;
            i++
        ) {
            if (videoComments[_videoId][_commentId].repliesIds[i] == _replyId) {
                delete (videoComments[_videoId][_commentId].repliesIds[i]);
            }
        }
    }

    function likeReply(
        uint256 _videoId,
        uint256 _commentId,
        uint256 _replyId
    ) public {
        require(userId[msg.sender] != 0);

        uint256 _LikesIndex = _alreadyReact(
            commentReplies[_videoId][_commentId][_replyId].likes,
            msg.sender
        );
        uint256 _DislikeIndex = _alreadyReact(
            commentReplies[_videoId][_commentId][_replyId].dislike,
            msg.sender
        );

        if (_LikesIndex == 0) {
            commentReplies[_videoId][_commentId][_replyId].likes.push(
                msg.sender
            );

            if (_DislikeIndex > 0) {
                delete (
                    commentReplies[_videoId][_commentId][_replyId].dislike[
                        _DislikeIndex - 1
                    ]
                );
            }
        } else {
            delete (
                commentReplies[_videoId][_commentId][_replyId].likes[
                    _LikesIndex - 1
                ]
            );
        }
    }

    function dislikeReply(
        uint256 _videoId,
        uint256 _commentId,
        uint256 _replyId
    ) public {
        require(userId[msg.sender] != 0);

        uint256 _LikesIndex = _alreadyReact(
            commentReplies[_videoId][_commentId][_replyId].likes,
            msg.sender
        );
        uint256 _DislikeIndex = _alreadyReact(
            commentReplies[_videoId][_commentId][_replyId].dislike,
            msg.sender
        );

        if (_DislikeIndex == 0) {
            commentReplies[_videoId][_commentId][_replyId].dislike.push(
                msg.sender
            );

            if (_LikesIndex > 0) {
                delete (
                    commentReplies[_videoId][_commentId][_replyId].likes[
                        _LikesIndex - 1
                    ]
                );
            }
        } else {
            delete (
                commentReplies[_videoId][_commentId][_replyId].dislike[
                    _DislikeIndex - 1
                ]
            );
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Videos.sol";

contract Comments is Videos {
    //  -------------------- Comment functions ---------------------:

    function addComment(uint256 _videoId, string memory _commentMessag) public {
        require(userId[msg.sender] != 0);
        uint256 _commentId = videos[_videoId].commentsIds.length + 1;

        comment storage _comment = videoComments[_videoId][_commentId];
        _comment.id = _commentId;
        _comment.owner = msg.sender;
        _comment.comment = _commentMessag;
        _comment.timestamp = block.timestamp;
        videos[_videoId].commentsIds.push(_commentId);
    }

    function getVideoComment(uint256 _videoId, uint256 _commentId)
        public
        view
        returns (comment memory)
    {
        return videoComments[_videoId][_commentId];
    }

    function deletComment(uint256 _videoId, uint256 _commentId) public {
        require(userId[msg.sender] != 0);
        require(
            videoComments[_videoId][_commentId].owner == msg.sender ||
                videos[_videoId].owner == msg.sender
        );

        delete (videoComments[_videoId][_commentId]);
        for (uint256 i = 0; i < videos[_videoId].commentsIds.length; i++) {
            if (videos[_videoId].commentsIds[i] == _commentId) {
                delete (videos[_videoId].commentsIds[i]);
            }
        }
    }

    function likeComment(uint256 _videoId, uint256 _commentId) public {
        require(userId[msg.sender] != 0);
        uint256 _LikesIndex = _alreadyReact(
            videoComments[_videoId][_commentId].likes,
            msg.sender
        );
        uint256 _DislikeIndex = _alreadyReact(
            videoComments[_videoId][_commentId].dislike,
            msg.sender
        );

        if (_LikesIndex == 0) {
            videoComments[_videoId][_commentId].likes.push(msg.sender);
            if (_DislikeIndex > 0) {
                delete (
                    videoComments[_videoId][_commentId].dislike[
                        _DislikeIndex - 1
                    ]
                );
            }
        } else {
            delete (videoComments[_videoId][_commentId].likes[_LikesIndex - 1]);
        }
    }

    function dislikeComment(uint256 _videoId, uint256 _commentId) public {
       require(userId[msg.sender] != 0);
        uint256 _LikesIndex = _alreadyReact(
            videoComments[_videoId][_commentId].likes,
            msg.sender
        );
        uint256 _DislikeIndex = _alreadyReact(
            videoComments[_videoId][_commentId].dislike,
            msg.sender
        );

        if (_DislikeIndex == 0) {
            videoComments[_videoId][_commentId].dislike.push(msg.sender);
            if (_LikesIndex > 0) {
                delete (
                    videoComments[_videoId][_commentId].likes[
                        _LikesIndex - 1
                    ]
                );
            }
        } else {
            delete (videoComments[_videoId][_commentId].dislike[_DislikeIndex - 1]);
        }

      
    }
}