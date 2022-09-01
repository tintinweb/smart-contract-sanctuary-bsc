/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

/**
 * @title PointTube
 */
contract PointTube {
    uint256 public fileCount = 0;

    struct File {
        uint256 fileId;
        string fileName;
        string fileUri;
        address uploader;
        uint256 timestamp;
    }

    mapping(uint256 => File) public files;
    mapping(address => File[]) public userLinkedFiles;

    struct Comment {
        address user;
        string message;
        uint256 timestamp;
    }

    mapping(uint256 => Comment[]) public comments;
    mapping(address => File[]) public playlist;

    struct Like{
        uint256 counter;
        mapping(address => bool) addresses;
    }

    mapping(uint256 => Like) public likes;

    /**
    * Events
    */

    event FileUploaded(
        uint256 fileId,
        string fileName,
        string fileUri,
        address uploader,
        uint256 timestamp
    );

    event Commented(
        address user,
        string message,
        uint256 timestamp
    );

    /**
    * @dev uploadVideo function use to upload the file metadata to the smart contract files mapping
    * @param _fileName : name of the file
    * @param _fileUri : uri of the file metadata
    */

    function uploadVideo(
        string memory _fileName,
        string memory _fileUri
    ) public {
        require(bytes(_fileName).length > 0);
        require(bytes(_fileUri).length > 0);
        require(msg.sender != address(0));
        
        // increase the number of the files is using a counter
        fileCount++;

        files[fileCount] = File(
            fileCount,
            _fileName,
            _fileUri,
            msg.sender,
            block.timestamp
        );
        
        // From the frontend application
        // we can listen the events emitted from
        // the smart contract in order to update the UI.
        emit FileUploaded(
            fileCount,
            _fileName,
            _fileUri,
            msg.sender,
            block.timestamp
        );

        userLinkedFiles[msg.sender].push(files[fileCount]);
    }

    /**
    * @dev updateVideo function use to update the file metadata to the smart contract files mapping
    * @param _fileId : id of the file
    * @param _fileName : name of the file
    * @param _fileUri : uri of the file metadata
    */

    function updateVideo(
        uint256 _fileId,
        string memory _fileName,
        string memory _fileUri
    ) public {
        require(bytes(_fileName).length > 0);
        require(bytes(_fileUri).length > 0);
        require(msg.sender != address(0));

        File storage file = files[_fileId];
        file.fileName =  _fileName;
        file.fileUri = _fileUri;
        file.timestamp = block.timestamp;
    }

    // get detail of specific video file to show

    function getVideo(uint256 fileId)
        public
        view
        returns (
            File memory
        )
    {
        return files[fileId];
    }

    // get videos of specific user

    function getVideos(address _address)
        public
        view
        returns (
            File[] memory
        )
    {
        return userLinkedFiles[_address];
    }

    /**
    * @dev like function use to like the specific video from frontend
    * @param _fileId : id of the file
    */

    function like(
        uint256 _fileId
    ) public {
        Like storage likeObj = likes[_fileId];
        require(likeObj.addresses[msg.sender] == false,"you have already like this video");
        likeObj.counter++;
        likeObj.addresses[msg.sender] = true;
    }

    // get total number of likes of specific video

    function getLikes(uint256 fileId)
        public
        view
        returns (
            uint256
        )
    {
        return (
            likes[fileId].counter
        );
    }

    /**
    * @dev dislike function use to dislike the specific video from frontend
    * @param _fileId : id of the file
    */

    function dislike(
        uint256 _fileId
    ) public {
        Like storage likeObj = likes[_fileId];
        bool status = likeObj.addresses[msg.sender];
        likeObj.addresses[msg.sender] = false;
        require(status == true && likeObj.counter > 0);
        likeObj.counter--;
    }

    /**
    * @dev comment function use to store the user's comment to the smart contract comments mapping
    * @param _message : message which user will type
    * @param _fileId : id of the file
    */

    function comment(
        string memory _message,
        uint256 _fileId
    ) public {
        require(bytes(_message).length > 0);
        require(msg.sender != address(0));

        comments[_fileId].push(Comment(
            msg.sender,
            _message,
            block.timestamp
        ));
        
        // From the frontend application
        // we can listen the events emitted from
        // the smart contract in order to update the UI.
        emit Commented(
            msg.sender,
            _message,
            block.timestamp
        );
    }

    // get total comments of specific video

    function getComments(uint256 fileId)
        public
        view
        returns (
            Comment[] memory
        )
    {
        return comments[fileId];
    }

    /**
    * @dev addToPlaylist function use to store the user selected video to the smart contract playlist mapping
    * @param _fileId : id of the file
    */

    function addToPlaylist(
        uint256 _fileId
    ) public {
        bool flag = false;
        for (uint256 i = 0; i < playlist[msg.sender].length; i++) 
        { 
            if (playlist[msg.sender][i].fileId == _fileId)
            {
                flag = true;
                break;
            }
        }

        require(flag == false, "you have already added this video in playlist");
        playlist[msg.sender].push(files[_fileId]);
    }

    // get playlist of specific user

    function getPlaylist(address _address)
        public
        view
        returns (
            File[] memory
        )
    {
        return playlist[_address];
    }
}