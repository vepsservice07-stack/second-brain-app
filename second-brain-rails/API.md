# Second Brain API Documentation

Base URL: `/api/v1`

## Authentication

Currently no authentication required. Will be added in future version.

## Endpoints

### List Notes

```
GET /api/v1/notes
```

Returns up to 100 most recent notes.

**Response:**
```json
{
  "notes": [
    {
      "id": 1,
      "title": "Note Title",
      "sequence_number": 12345,
      "tag_ids": [1, 2],
      "wiki_links": ["Other Note"],
      "created_at": "2024-12-09T12:00:00Z",
      "updated_at": "2024-12-09T13:00:00Z"
    }
  ],
  "total": 42
}
```

### Get Note

```
GET /api/v1/notes/:id
```

**Response:**
```json
{
  "note": {
    "id": 1,
    "title": "Note Title",
    "content": "Note content...",
    "sequence_number": 12345,
    "tag_ids": [1, 2],
    "wiki_links": [],
    "created_at": "2024-12-09T12:00:00Z",
    "updated_at": "2024-12-09T13:00:00Z"
  }
}
```

### Create Note

```
POST /api/v1/notes
Content-Type: application/json

{
  "note": {
    "title": "New Note",
    "content": "Content here",
    "tag_ids": [1, 2]
  }
}
```

### Update Note

```
PATCH /api/v1/notes/:id
Content-Type: application/json

{
  "note": {
    "title": "Updated Title",
    "content": "Updated content"
  }
}
```

### Delete Note

```
DELETE /api/v1/notes/:id
```

Performs soft delete.

### Search Notes

```
GET /api/v1/notes/search?q=query
```

**Response:**
```json
{
  "notes": [...],
  "query": "search term",
  "total": 5
}
```

## Export

### Export All Data

```
GET /export/all?format=json
GET /export/all?format=markdown
```

Downloads complete export of all notes and tags.
