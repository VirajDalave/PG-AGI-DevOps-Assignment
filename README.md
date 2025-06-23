Video link: "https://drive.google.com/file/d/1otPljcy83ki44KjLJG2ZPCilDGQv5wxc/view?usp=drive_link"

# DevOps Assignment

This project consists of a FastAPI backend and a Next.js frontend that communicates with the backend.

## Project Structure

```
.
├── backend/               # FastAPI backend
│   ├── app/
│   │   └── main.py       # Main FastAPI application
│   └── requirements.txt    # Python dependencies
└── frontend/              # Next.js frontend
    ├── pages/
    │   └── index.js     # Main page
    ├── public/            # Static files
    └── package.json       # Node.js dependencies
```

## Prerequisites

- Python 3.8+
- Node.js 16+
- npm or yarn

## Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Create a virtual environment (recommended):
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: .\venv\Scripts\activate
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Run the FastAPI server:
   ```bash
   uvicorn app.main:app --reload --port 8000
   ```

   The backend will be available at `http://localhost:8000`

## Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install dependencies:
   ```bash
   npm install
   # or
   yarn
   ```

3. Configure the backend URL (if different from default):
   - Open `.env.local`
   - Update `NEXT_PUBLIC_API_URL` with your backend URL
   - Example: `NEXT_PUBLIC_API_URL=https://your-backend-url.com`

4. Run the development server:
   ```bash
   npm run dev
   # or
   yarn dev
   ```

   The frontend will be available at `http://localhost:3000`

## Changing the Backend URL

To change the backend URL that the frontend connects to:

1. Open the `.env.local` file in the frontend directory
2. Update the `NEXT_PUBLIC_API_URL` variable with your new backend URL
3. Save the file
4. Restart the Next.js development server for changes to take effect

Example:
```
NEXT_PUBLIC_API_URL=https://your-new-backend-url.com
```

## For deployment:
   ```bash
   npm run build
   # or
   yarn build
   ```

   AND

   ```bash
   npm run start
   # or
   yarn start
   ```

   The frontend will be available at `http://localhost:3000`

## Testing the Integration

1. Ensure both backend and frontend servers are running
2. Open the frontend in your browser (default: http://localhost:3000)
3. If everything is working correctly, you should see:
   - A status message indicating the backend is connected
   - The message from the backend: "You've successfully integrated the backend!"
   - The current backend URL being used

## API Endpoints

- `GET /api/health`: Health check endpoint
  - Returns: `{"status": "healthy", "message": "Backend is running successfully"}`

- `GET /api/message`: Get the integration message
  - Returns: `{"message": "You've successfully integrated the backend!"}`

# My Implementation
## Prerequisites
- terraform
- aws iam user access keys

## Repository setup
1. Fork the repository
2. Add secrets `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to your repository

## Infrastructure setup
1. clone the repository
2. `git checkout develop` branch
3. `cd infra/backend` and `terraform init`, `terraform plan` and `terraform apply`.
   This will crete the remote backend and state locking using s3 and dynamodb
4. create a secret in AWS Systems Manager using AWS Console or by
   `cd infra/modules/secrets`, `terraform init`, `terraform plan` and `terraform apply`
5. Create ECR repositories named "pgagi-backend" and "pgagi-frontend"

## CICD
1. create a feature branch or make the code changes you want on develop branch and push the changes.
   This will trigger the CI-pipeline and push the images to ECR with appropriate tag.
   Also the tag will be stored as a secret that will be used while deploying.
2. Create a pull request to the main branch and merge after reviewing.
   This will trigger the CD-pipeline.
3. Access the application using the alb dns name received as a terraform output.

