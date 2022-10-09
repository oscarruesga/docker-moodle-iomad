docker-moodle-iomad
===================

A Dockerfile that installs and runs the  IOMAD  stable, with Iomad and external MySQL Database.


`Note: DB Deployment uses version 5.7 of MySQL. MySQL:Latest is now v8.`

Tags:
* latest - 4.0 stable
* v3.9 - 3.9 stable

## Installation

```
git clone https://github.com/oscarruesga/docker-moodle-iomad
cd docker-moodle
docker build -t moodle .
```

## Usage

Test Environment

When running locally or for a test deployment, use of localhost is acceptable.

To spawn a new instance of Moodle:

```
docker run -d --name DB -p 3306:3306 -e MYSQL_DATABASE=moodle -e MYSQL_ROOT_PASSWORD=moodle -e MYSQL_USER=moodle -e MYSQL_PASSWORD=moodle mysql:5.7
docker run -d -P --name moodle --link DB:DB -e MOODLE_URL=http://localhost smezei/moodle-iomad
```

You can visit the following URL in a browser to get started:

```
http://localhost
```

### Production Deployment

For a production deployment of moodle, use of a FQDN is advised. This FQDN should be created in DNS for resolution to your host. For example, if your internal DNS is company.com, you could leverage moodle.company.com and have that record resolve to the host running your moodle container. The moodle url would then be, `MOODLE_URL=http://moodle.company.com`
In the following steps, replace MOODLE_URL with your appropriate FQDN.

* Deploy With Docker
```
docker run -d --name DB -p 3306:3306 -e MYSQL_DATABASE=moodle -e MYSQL_ROOT_PASSWORD=moodle -e MYSQL_USER=moodle -e MYSQL_PASSWORD=moodle mysql:5
docker run -d -P --name moodle --link DB:DB -e MOODLE_URL=http://moodle.company.com -p 80:80 smezei/moodle-iomad
```

* Deploy with Docker Compose

Pull the latest source from GitHub:
```
git clone https://github.com/oscarruesga/docker-moodle-iomad
```

Update the `moodle_variables.env` file with your information. Please note that we are using v3 compose files, as a stop gap link env variable are manually filled since v3 no longer automatically fills those for use.

Once the environment file is filled in you may bring up the service with:
`docker-compose up -d`



## Caveats
The following aren't handled, considered, or need work: 
* moodle cronjob (should be called from cron container)
* log handling (stdout?)
* email (does it even send?)

## Credits

This is a fork of Smezei's](https://github.com/smezei/docker-moodle-iomad) Dockerfile.

